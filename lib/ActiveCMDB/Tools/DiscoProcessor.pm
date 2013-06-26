use utf8;
package ActiveCMDB::Tools::DiscoProcessor;

=begin nd

    Script: ActiveCMDB::Tools::DiscoProcessor.pm
    ___________________________________________________________________________

    Version 1.0

    Copyright (C) 2011-2015 Theo Bot

    http://www.activecmdb.org


    Topic: Purpose

    ActiveCMDB::Tools::DiscoProcessor class definition

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
	
	This is the actual discovery processor
	
	
=cut

#################################################################
# Initialize modules
use Moose;
use Logger;
use Switch;
use DateTime;
use ActiveCMDB::Object::Process;
use ActiveCMDB::Tools::Common;
use ActiveCMDB::ConfigFactory;
use ActiveCMDB::Common::Broker;
use ActiveCMDB::Common::Constants;
use ActiveCMDB::Model::CMDBv1;
use Data::Dumper;
use Carp qw(cluck);

with 'ActiveCMDB::Tools::Common';
has 'disco' 	=> (is => 'rw', isa => 'Hash' );
use constant CMDB_PROCESSTYPE => 'disco';

no strict 'refs';

sub init {
	my($self, $args) = @_;
	
	Logger->info("Initializing discovery processor");
	$self->{signal_raised} = false;
	$self->config(ActiveCMDB::ConfigFactory->instance());
	$self->config->load('cmdb');
	
	$self->process( ActiveCMDB::Object::Process->new(
			name		=> CMDB_PROCESSTYPE,
			instance	=> $args->{instance},
			server_id	=> $self->config->section('cmdb::default::server_id'),
		)
	);
	$self->process->get_data();
	
	$self->process->type(CMDB_PROCESSTYPE);
	$self->process->status(PROC_RUNNING);
	$self->process->pid($$);
	$self->process->ppid(getppid());
	$self->process->path($self->config->section('cmdb::process::' . CMDB_PROCESSTYPE . '::path'));
	$self->process->update($self->process->process_name());
	
	$self->interrogations(undef);
	#
	# Loading device classes
	#
	$self->class_loader();
	
	#
	# Connecting to database
	#
	$self->schema(ActiveCMDB::Model::CMDBv1->instance());
	
	#
	# Connect to broker
	#
	$self->broker(ActiveCMDB::Common::Broker->new( $self->config->section('cmdb::broker') ));
	$self->broker->init({ 
							process   => $self->process,
							subscribe => true
						});
	
	
	#
	# Disconnect fromn tty and start new session
	#
	$self->process->disconnect();
}




=item process

Process messages to discover devices

=cut

sub processor
{
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
		$msg = $self->broker->getframe({ process_type => $self->process->type });
		if ( $msg ) {
			
			switch ( $msg->subject )
			{
				case 'ProcessDevice'	{ $self->process_device($msg) }
				case 'Shutdown'			{ $self->process->status(PROC_SHUTDOWN) }
				else					{ Logger->warn("Undefined message type ".$msg->subject )}
			}
			$delay--;
			
			Logger->debug("Message processed");
		}
		
		#
		# Make sure we don't start using too much cpu
		#
		if ( $delay > 0 ) {
			$self->process->action("Sleeping");
			$self->process->status(PROC_IDLE);
			$self->process->pid($$);
			$self->process->update($self->process->process_name);
			sleep $delay;
		}
	}	
}

sub process_device
{
	my($self, $msg) = @_;
	my($rs, $message, $device, $res, $t1, $t2);
	
	
	if ( defined($msg->payload ) )
	{
		
		Logger->info("Processing order ".$msg->cid . " device_id ". $msg->payload->{device}->{device_id});
		
		#
		# Create default device object
		#
		my $device = Class::Device->new(device_id => $msg->payload->{device}->{device_id});
		#
		# Get device discovery data
		#
		$device->get_data();
		$t1 = time();
		$t2 = undef;
		
		$self->process->status(PROC_BUSY);
		$self->process->action("Processing device " . $device->attr->hostname );
		$self->process->update();
		
		if ( defined($device->attr->mgtaddress()) ) {
			if ( $device->ping() ) 
			{
				Logger->debug("Device is reachable");
				my $oid = $device->get_oid_by_name('sysObjectID') || cluck($!);
				$res = $device->snmp_get($oid);
				#print "::> ", $device->attr->sysobjectid,"\n";
				if ( defined($res->{$oid}) && $res ne $device->attr->sysobjectid )
				{
					Logger->info("Setting sysObjectID to $res->{$oid}");
					$device->attr->sysObjectID($res);
				}
				my $device_class = $self->get_class_by_oid($device->attr->sysobjectid);
				if ( $device_class ne 'Class::Device' ) {
					Logger->debug("Switch device class to $device_class");
					#
					# Create device specific object
					#
					$device = $device_class->new(device_id => $device->device_id);
					$device->get_data();
				}
				$self->discover($device);
				$t2 = time();
				$device->attr->journal({ prio => 5, user => $self->process->process_name(), text => 'Discovery finished', date => DateTime->now()  });
			} else {
				Logger->warn("Device unreachable");
			}
		} else {
			#
			# Device cannot be discovered due to missing address
			#
			Logger->warn("Missing network address");
		}
		if ( defined($t2) )
		{
			$device->set_disco($t2 - $t1);
		}
	
		#
		# Acknowledge the order to the sender
		#
		$message = ActiveCMDB::Object::Message->new();
		$message->from($self->process->type);
		$message->subject('AckProcessDevice');
		$message->payload($msg->payload);
		$message->cid($msg->cid);
		$message->to($msg->reply_to);
		$self->broker->sendframe($message);
	} else {
		Logger->warn("No device_id found in payload");
	}
}

sub discover
{
	my($self, $device) = @_;
	my(%disco);
	my(@discos) = ();
	my($class, $result, $cycles);
	Logger->info("Starting discovery for ".$device->attr->hostname);
	
	$class = ref $device;
	if ( defined($self->{classes}->{$class} ) )
	{
		#
		# Reset results
		#
		$result = undef; 
		#
		# Reset interrogations
		#
		%disco = ();
		#
		# Get New interrogations
		#
		Logger->info("Getting interrogations for $class");
		%disco = $self->interrogations($class, %disco);
		Logger->debug("\n" . Dumper(%disco));
		$cycles = 0;
		foreach (keys %disco) {
			if ( $disco{$_} > $cycles ) { $cycles = $disco{$_}; }
		}
		Logger->info("Passing $cycles cycles");
		#
		# Start device interrogation
		#
		
		for (my $i = 1; $i <= $cycles; $i++)
		{
			Logger->debug("Discovery cycle $i");
			foreach my $key (keys %disco)
			{
				if ( $disco{$key} == $i ) {
					Logger->debug("Discovering $key");
					my $method = 'discover_' . $key;
					if ( $result->{$key} = $device->$method($result) ) 
					{
						push(@discos, $key);
					}
				}
			}
			
			#
			# Save discovered data
			#
			
		
			Logger->info("Saving data");
			foreach my $key (@discos)
			{
				my $method = 'save_' . $key;
				$device->$method($result->{$key});
			}
			
			# Reset @discos, so we don't have to save 'm again
			@discos =();
			
		}
		
		
	}
	Logger->info("Discovery finished for " . $device->attr->hostname);
	$device->DESTROY;
	
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

sub interrogations
{
	my($self, $class, %disco ) = @_;
	
	if ( defined($class) && defined($self->{classes}->{$class}) )
	{
		foreach my $key (keys %{$self->{classes}->{$class}->{interrogations}})
		{
			if ( !defined($disco{$key}) && $self->{classes}->{$class}->{interrogations}->{$key} >= 1 ) {
				$disco{$key} = $self->{classes}->{$class}->{interrogations}->{$key};
			}
		}
		
		if ( defined($self->{classes}->{$class}->{super}) )
		{
			my $super = 'Class::' . $self->{classes}->{$class}->{super};
			if ( defined($self->{classes}->{$super}) ) 
			{
				%disco = $self->interrogations($super, %disco);
			}
			
		}
	}
	
	return %disco ;
}

1;