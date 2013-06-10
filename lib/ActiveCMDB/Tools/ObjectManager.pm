use utf8;
package ActiveCMDB::Tools::ObjectManager;

=begin nd

    Script: ActiveCMDB::Tools::ObjectManager.pm
    ___________________________________________________________________________

    Version 1.0

    Copyright (C) 2012-2013 Theo Bot

    http://www.activecmdb.org


    Topic: Purpose

    ActiveCMDB::Tools::ProcessManager class definition

    About: License

    This program is free software; you can redistribute it and/or
    modify it under the terms of the GNU General Public License
    as published by the Free Software Foundation; either version 2
    of the License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    Topic: Release information

    $Rev$

	Topic: Description
	
	This is the ip device object manager
	

=cut

use Moose;
use Switch;
use Time::localtime;
use Logger;
use ActiveCMDB::Tools::Common;
use ActiveCMDB::ConfigFactory;
use ActiveCMDB::Common::Broker;
use ActiveCMDB::Common::Constants;
use ActiveCMDB::Model::CMDBv1;
use ActiveCMDB::Schema;
use ActiveCMDB::Object::Maintenance;
use ActiveCMDB::Object::Process;

use Data::Dumper;

use constant CMDB_PROCESSTYPE => 'object';

my(@schemes) = ();
my %schemas = ();

has 'schema_age'	=> ( is => 'rw', isa => 'Int' );
has 'object_store'	=> (
		traits	=> ['Hash'], 
		is		=> 'rw',
		isa		=> 'HashRef',
		default	=> sub { {} },
		handles	=> {
			store_object	=> 'set',
			fetch_object	=> 'get',
			delete_object	=> 'delete',
		}
	);
	
with 'ActiveCMDB::Tools::Common';

sub init {
	my($self, $args) = @_;
	
	Logger->info("Starting ip object manager");

	$self->config(ActiveCMDB::ConfigFactory->instance());
	$self->config->load('cmdb');
	$self->process( ActiveCMDB::Object::Process->new(
			name		=> CMDB_PROCESSTYPE,
			instance	=> $args->{instance},
			server_id	=> $self->config->section('cmdb::default::server_id')
		)
	);
	$self->process->get_data();
	$self->reset_signal(false);
	$self->process->status(PROC_RUNNING);
	$self->process->pid($$);
	$self->process->update($self->process->process_name());
	$self->process->disconnect();
	$self->schema_age(0);
	#
	# Connecting to database
	#
	$self->schema(ActiveCMDB::Schema->connect(ActiveCMDB::Model::CMDBv1->config()->{connect_info}));
	
	#
	# Connect to broker
	#
	$self->broker(ActiveCMDB::Common::Broker->new( $self->config->section('cmdb::broker') ));
	$self->broker->init({ 
							process   => $self->process,
							subscribe => true
						});
	
	$self->start_childern();
	
}

sub manage {
	my($self) = @_;
	
	my($msg, $delay);
	
	while ( $self->process->status != PROC_SHUTDOWN )
	{
		# Reset delay timer
		$delay = 5;
		
		#
		# Handle raised signals
		#
		if ( $self->raise_signal == true ) {
			Logger->debug("Seems a signal has been raised");
			$self->handle_signals();
			$self->raise_signal(false);
			next;
		}
		
		#
		# Check if there is a message at the broker
		#
		$msg = $self->{broker}->getframe();
		
		if ( $msg ) {
			switch ( $msg->subject )
			{
				case 'ProcessDevice'			{ $self->process_device($msg->payload) }
				case 'AckProcessDevice'			{ $self->ack_order($msg) }
				case 'Shutdown'					{ $self->running(PROC_SHUTDOWN) }
				case 'DiscoverDevice'			{ 
												  $self->process_device({ 	device_id	=> $msg->payload->{device}->{device_id},
																			dest		=> [ $self->config->section("cmdb::process::disco::queue") ],
																			priority	=> PRIO_HIGH 
																		  }); 
												}
				case 'FetchConfig'				{
												   $self->process_device({	device_id	=> $msg->payload->{device}->{device_id},
												   							dest		=> [ $self->config->section("cmdb::process::config::queue") ],
												   							priority	=> PRIO_HIGH
												   						});
												}
				else	{ Logger->warn("Undefined message type ".$msg->subject ) }
			}
			$delay--;
		}
		
		#
		# Check if there are new devices to be processed
		#
		if ( $self->low_water() ) {
			$self->process_devices();
			$delay--;
		}
		
		#
		# Make sure we don't start too much cpu
		#
		if ( $delay > 0 ) {
			sleep $delay;
		}
	}
}

=item low_water

Check the size of the queue,

=cut
sub low_water
{
	my($self) = @_;
	my($count, $low_water);
	my(@follow_up);
	
	
	@follow_up = split(/\,/, $self->config->section("cmdb::process::object::follow_up"));
	$low_water = $self->config->section("cmdb::process::object::low_water");
	Logger->debug("Testing the low_water mark ($low_water)");
	$count = $self->schema->resultset('DeviceOrder')->count({
		dest => { -in => [ @follow_up ]}
	});
	
	if ( $count < $low_water ) {
		Logger->info("Low water mark reached");
		return TRUE;
	}
}

=item process_devices

This routine selects device id's to be processed. Not parameters to be passed.

=cut 

sub process_devices
{
	my($self) = @_;
	Logger->info("Processing devices");
	my($rs, $ts, $rs_inside);
	
	#
	# Processing maintenance 
	#
	$self->maintenance();
	
	$ts = time() - $self->config->section("cmdb::process::object::reprocess_intervall");
	
	Logger->info("Fetching current orders");
	$rs_inside = $self->schema->resultset('DeviceOrder')->search(
				{
				},
				{
					columns		=> [qw/device_id/]
				}
			);
	
	Logger->info("Fetching new devices.");
	#Logger->debug("Active schemas: ". $self->active_schemes());
	
	$rs = $self->schema->resultset('IpDevice')->search(
				{
					status		=> 0,
					disco		=> { '<' 		=> $ts },
					device_id	=> { -not_in	=> $rs_inside->get_column("device_id")->as_query },
					'sysoids.disco_scheme' => { -in => $self->active_schemes() }
				},
				{
					join		=> 'sysoids',
					columns		=> [qw/device_id/],
					order_by	=> 'disco',
					rows		=> $self->config->section("cmdb::process::object::reprocess_limit") || 1
				}
	
			);
			
	#
	# Process the results
	#
	
	Logger->info("Found " . $rs->count . " device(s)");

	while ( my $row = $rs->next )
	{
		Logger->debug("Found device_id " . $row->device_id);
		my $device = ActiveCMDB::Object::Device->new( device_id => $row->device_id  );
		$device->get_data();
		$self->process_device({
					device	=> $device,
					dest	=> [ split(/\,/, $self->config->section("cmdb::process::object::follow_up")) ]
				});
	}
	Logger->info("Done fetching");
}

=item ack_order

=cut

sub ack_order
{
	my($self, $msg) = @_;
	my($rs);
	
	Logger->info("Acknowledged order " . $msg->cid);
	$rs = $self->schema->resultset('DeviceOrder')->search({ cid => $msg->cid });
	if ( $rs != 0 ) {
		$rs->delete;
		Logger->debug("Order removed");
	}
	
	#
	# If there is a follow-up, forward the message
	#
	if ( defined( $self->config->section("cmdb::process::".$msg->from."::follow_up")) )
	{
		foreach my $dest ( split(/\,/, $self->config->section("cmdb::process::".$msg->from."::follow_up")) )
		{
			$msg->from($self->process->name);
			$msg->subject("ProcessDevice");
			$msg->to( $self->config->section("cmdb::broker::prefix") . $dest );
			$self->broker->sendframe($msg);
		}
	}
}

=item process_device

=cut

sub process_device
{
	my($self, $args) = @_;
	my($message, $p);
	
	$message = ActiveCMDB::Object::Message->new();
	$message->from($self->process->name);
	$message->reply_to($self->config->section("cmdb::broker::prefix") . $self->process->process_name );
	$message->subject('ProcessDevice');
	
	$self->store_object('device', $args->{device});
	$self->store_object('message', $message);
	
	
	foreach my $dest ( @{$args->{dest}} )
	{
		Logger->debug("Sending message to $dest");
		
		
		
		$message->to( $self->config->section("cmdb::broker::prefix") . $dest );
		$message->cid($self->uuid());
		$self->broker->sendframe($message, $args);
		$self->create_order($message, $dest);
	}
	
}



sub create_order
{
	my($self, $message, $dest) = @_;
	$self->schema->resultset('DeviceOrder')->create(
						{
							cid			=> $message->cid(),
							device_id	=> $message->payload->{device}->{device_id},
							ts			=> time(),
							dest		=> $dest
						}
					);
}

sub handle_signals
{
	my($self) = @_;
	Logger->warn("Handling incoming signal");
	foreach my $sig (keys $self->{signal})
	{
		Logger->debug("Processing signal $sig");
		switch ($sig)
		{
			case 'INT'		{ $self->process->status(PROC_SHUTDOWN); }
			case 'TERM'		{ $self->process->status(PROC_SHUTDOWN); }
		}
	}
}

sub active_schemes
{
	my($self) = @_;
	
	my($now, $tm, $mins);	
	
	@schemes = ();
	Logger->debug("Get active schemes");
	$now = time();
	if ( $now - $self->schema_age > $self->schema_max_age ) {
		Logger->info("Schemas are out of date, refreshing");
		@schemes = ();
		%schemas = $self->update_schemas();
		$self->schema_age(time());
	}
	
	
	# Create localtime object
	$tm = localtime($now);
	
	# Get the current number of past minutes in this dat
	$mins = $tm->min + (60 * $tm->hour);
	foreach my $id ( keys %schemas )
	{
		Logger->debug("Processing schema id: $id");
		my $schema = $schemas{$id};
		my @b1 = split(/\;/, $schema->block1,2);
		my @b2 = split(/\;/, $schema->block2,2);
		Logger->debug("Current value $mins");
		Logger->debug("Matching scheme: $id Block1: @b1");
		Logger->debug("         scheme: $id Block2: @b2");
		if ( 
				( $b1[0] != $b1[1]  && ( $mins >= $b1[0]  && $mins <= $b1[1] ) ) || 
				( $b2[0] != $b2[1]  && ( $mins >= $b2[0]  && $mins <= $b2[1] ) )  
			)
		{
			push(@schemes, $id);
		}
	}
	
	#
    # Add a dummy scheme to be sure there is a value in the array
    #
    push(@schemes, -1);
	
	
	return join(',',@schemes);
}

sub update_schemas {
	my($self) = @_;
	my $rs;
	my %schemas = ();
	Logger->debug("Updating active schemas");
	$rs = $self->schema->resultset('DiscoScheme')->search(
								{ active => 1 },
								{ 
									columns  => [qw/scheme_id block1 block2/],
								  	order_by => 'scheme_id'
								}	
							);
	while ( my $schema = $rs->next )
	{
		$schemas{$schema->scheme_id} = $schema;
	}
	
	return %schemas;
}

sub active_maintenance {
	my($self) = @_;
	my($m, $rs, $row);
	my $active = undef;
	
	$active->{active}->{-1} = 1;
	$active->{inactive}->{-1} = 1;
	
	Logger->debug("Fetching active maintenance schedules");
	$rs = $self->schema->resultset("Maintenance")->search(
			{
			},
			{
				columns => qw/maint_id/
			}
	);
	while( $row = $rs->next )
	{
		$m = ActiveCMDB::Object::Maintenance->new(maint_id => $row->maint_id);
		$m->get_data();
		if ( $m->is_active() ) {
			$active->{active}->{ $row->maint_id } = 1;
		} else {
			$active->{inactive}->{ $row->maint_id } = 0;
		}
	} 
	
	return $active;
}

sub maintenance {
	my($self) = @_;
	my $maintenance = undef;
	my($rs1a,$rs1b,$rs2);
	my %active = ();
	my %inactive = (); 
	
	#
	Logger->info("Processing maintenance schedules"); 
	
	
	$maintenance = $self->active_maintenance();
	%active   = %{ $maintenance->{active} };
	%inactive = %{ $maintenance->{inactive} };
	
	
	$rs1a = $self->schema->resultset("IpDeviceMaint")->search(
			{
				maint_id => { 'in' => [ keys %active ] }
			},
			{
				columns => qw/device_id/
			}
	);
	
	$rs1b = $self->schema->resultset("IpDeviceMaint")->search(
			{
				maint_id => { 'in' => [ keys %inactive ] }
			},
			{
				columns => qw/device_id/
			}
	);
	
	$rs2 = $self->schema->resultset("IpDevice")->search(
			{
				status => 1,
				device_id => { 'in' => $rs1b->get_column('device_id')->as_query }
			}
	);
	
	$rs2->update( { status => 0 } );
	
	$rs2 = $self->schema->resultset("IpDevice")->search(
			{
				status => 0,
				device_id => { 'in' => $rs1a->get_column('device_id')->as_query }
			}
	);
	
	$rs2->update( { status => 1 } );
	
}

sub schema_max_age {
	my($self) = @_;
	Logger->debug("Retrieving schema max age");
	
	return 300;
}

sub start_childern {
	my($self) = @_;
	Logger->debug("Starting childern");
}

sub poll_managers
{
	my($self) = @_;
	my($message);
	
	$message = ActiveCMDB::Object::Message->new();
	$message->from( $self->process->name );
	$message->reply_to( $self->config->section("cmdb::broker::prefix") . $self->process->process_name );
	$message->subject('PollObjectMngr');
	$message->to( $self->config->section("cmdb::process::object::exchange") );
	
	
}

__PACKAGE__->meta->make_immutable;

1;