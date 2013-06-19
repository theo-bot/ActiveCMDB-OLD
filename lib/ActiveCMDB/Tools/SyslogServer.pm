package ActiveCMDB::Tools::SyslogServer;

=head1 ActiveCMDB::Tools::SyslogServer

    ___________________________________________________________________________

    Version 1.0

=head1 Copyright

    Copyright (C) 2011-2015 Theo Bot

    http://www.activecmdb.org


    Topic: Purpose

    Syslog server to process config changes

=head1 License

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

#####################################################
# Initialize perl modules
use Moose;
use Switch;
use Net::Syslogd;
use strict;
use warnings;
use Tie::File::AsHash;
use Data::Dumper;
use ActiveCMDB::Common;
use ActiveCMDB::Object::Process;
use ActiveCMDB::Object::Device;
use ActiveCMDB::Object::Endpoint;
use ActiveCMDB::Tools::Common;
use ActiveCMDB::ConfigFactory;
use ActiveCMDB::Common::Broker;
use ActiveCMDB::Common::Constants;
use ActiveCMDB::Common::Tempfile;
use ActiveCMDB::Common::Device;
use ActiveCMDB::Model::CMDBv1;
use ActiveCMDB::Schema;

use constant CMDB_PROCESSTYPE => 'syslog';

=head1 Attributes

=head2 server

Attribute server containts the Net::Syslogd listerner object.

=cut

has 'server'	=> (
	is		=> 'rw',
	isa		=> 'Maybe[Object]',
);

=head2 expr

Attribute expr containts all expressions for matching syslog messages

=cut

has 'expr'		=> (
	traits	=> ['Array'],
	is		=> 'rw',
	isa		=> 'ArrayRef[Str]',
	default	=> sub { [] },
	handles	=> {
		expr_add	=> 'push',
		expressions	=> 'elements',
		expr_clear	=> 'clear',
		expr_count	=> 'count',
	}
);

=head2 object-store

Attribute object_store is a hash with objects containing current object data

$object_store{device} => Containts a ActiveCMDB::Object::Device object
$object_store{message} => Containts a ActiveCMDB::Object::Message object

This attribute can be passed on to the ActiveCMDB::Object::Enpoint::Message parse 
method. So the parse function knows where to which which data

=cut

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

=head2 expr_age

Attribute expr_age containt an integer value with the time that the expressions
were loaded.

=cut

has 'expr_age'	=> (
	is		=> 'rw',
	isa		=> 'Int',
	default	=> 0
);

=head2 buffer_time

Attribute buffer_time containts the oldest entry in the %deviceBuffer hash. So
it can be used to trigger the process_buffer method.

=cut

has 'buffer_time' => (
	is		=> 'rw',
	isa		=> 'Int',
	default	=> 0
);

=head2 deviceBuffer

The device buffer hash contains all device id's for we have received a syslog message
that matched an expression and is managed in our database. It is via the 
Tie::File::AsHash module connected to a file defined by the process:syslog::buffer entry
in the cmdb.yml file 

=cut

my %deviceBuffer;


with 'ActiveCMDB::Tools::Common';

=head1 Methods

=head2 init

The init method initalizes the process and is triggered only once 

Arguments:
$self	- Reference to the object
$args	- Hash reference containg the instance number

The configuration is loaded in this method:

 syslog:
    queue: cmdb.syslog
    exchange: cmdb.syslog-x
    path: $CMDB_HOME/sbin/cmdb_ip_syslog.pl
    follow_up: cmdbDisco,cmdbConfig
    server:
      LocalAddr: 192.168.178.20
      LocalPort: 514
      timeout: 2
    buffer: $CMDB_HOME/var/tmp/syslog.dat
    expfile: $CMDB_HOME/conf/syslog.exp
    expmaxage: 60
    delay_forward: 120

=cut

sub init 
{
	my($self, $args) = @_;
	
	Logger->info("Starting ip syslog manager");
	
	#
	# Import configuration
	#
	$self->config(ActiveCMDB::ConfigFactory->instance());
	$self->config->load('cmdb');
	$self->process( ActiveCMDB::Object::Process->new(
			name		=> CMDB_PROCESSTYPE,
			type		=> CMDB_PROCESSTYPE,
			instance	=> $args->{instance},
			server_id	=> $self->config->section('cmdb::default::server_id')
		)
	);

	#
	# Initialize process status
	#
	$self->process->get_data();
	$self->reset_signal(false);
	$self->process->status(PROC_RUNNING);
	$self->process->pid($$);
	$self->process->update($self->process->process_name());
	$self->process->disconnect();
	
	#
	# Connect to broker
	#
	$self->broker(ActiveCMDB::Common::Broker->new( $self->config->section('cmdb::broker') ));
	$self->broker->init({ 
							process   => $self->process,
							subscribe => true
						});
	
	#
	# Initialize server
	#
	my $cfg = $self->config->section("cmdb::process::syslog::server");
	my @cfg = ();
	foreach ( keys( %{$cfg} ) )
	{
		push(@cfg, $_ => $cfg->{$_});
	}
	Logger->debug("Creating syslog server with arguments:\n" . Dumper($cfg) );
	if ( $self->server( Net::Syslogd->new( @cfg ) ) )
	{
		Logger->info("Defined server object");
	} else {
		Logger->error("Failed to create server object " . Net::Syslogd->error);
	}
	
	#
	# Initialize device buffer
	#
	my $buffer = subst_envvar( $self->config->section("cmdb::process::syslog::buffer") );
	tie %deviceBuffer, 
		'Tie::File::AsHash', 
		subst_envvar($self->config->section("cmdb::process::syslog::buffer")), 
		split => ":";
		
	$self->set_buffertime();
}

=head2 processor

Main processing loop.

=cut 

sub processor
{
	my($self) = @_;
	my($msg, $delay);
	
	while ( $self->process->status != PROC_SHUTDOWN )
	{
		#
		# Reset delay timer
		#
		$delay = 2;
		
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
		# Check for new syslog messages
		#
		Logger->debug("Checking for syslog messages");
		my $logmsg = undef;
		$logmsg = $self->server->get_message();
		if ( defined($logmsg) && $logmsg )
		{
			$self->process_message($logmsg);
			$delay--;
		} else {
			if ( $logmsg == 0 )
			{
				Logger->debug("Timeout on message reception");
			} else {
				Logger->warn("Syslog error :" . Net::Syslogd->error);
			}
		}
		
		#
		# Process buffer contents
		#
		if ( time() - $self->buffer_time > $self->config->section("cmdb::process::syslog::delay_forward") )
		{
			$self->process_buffer();
			$delay--;
		}
		#
		# Check for messages at the broker
		#
		$msg = $self->broker->getframe({ process_type => $self->process->type });
		if ( $msg )
		{
			switch( $msg->subject )
			{
				case 'Shutdown'			{ $self->process->status(PROC_SHUTDOWN) }
				else 					{ Logger->warn("Undefined message type ".$msg->subject )}
			}
			$delay--;
			
			Logger->debug("Broker message processed");
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

=head2 process_message

Process a single syslog message. Decode a given message and match it against a
number of expressions. These expression will be refressed automatically from the
file configured in the cmdb.yml file (expfile). 

Arguments:
$self	: reference to object
$message: Net::Syslogd->get_message() result

=cut

sub process_message
{
	my($self, $message) = @_;
	
	Logger->debug("Processing syslog message");
	
	if ( time() - $self->expr_age > $self->config->section("cmdb::process::syslog::expmaxage") )
	{
		$self->import_expressions();
		$self->expr_age(time());
	}
	
	if ( !defined($message->process_message()) )
	{
		Logger->warn(Net::Syslogd->error);
	} else {
		my $match =false;
		Logger->debug("Got message: " . $message->message);
		foreach my $expr ( $self->expressions )
		{
			
			Logger->debug("Testing message agains $expr");
			
			if ( $message->message =~ /$expr/ ) {
				Logger->info("Found message for $expr");
				$match = true;
				last;
			} 
		}
		if ( ! $match ) {
			Logger->debug("Message did not match any expression");
		} else {
			my $device = cmdb_gethostByAddr( $message->remoteaddr );
			if ( defined($device) )
			{
				$deviceBuffer{ $device->device_id } = time();
				$self->set_buffertime();
			} else {
				Logger->debug("Unknown device " . $message->remoteaddr );
			}
		}
	}
}

=head2 process_buffer

Process the contents of the %deviceBuffer hash and check whether or not
the follow ups have to be informed of the change. Forwarding is delayed 
for a number of seconds. Configurations are often changed multiple times
so the server will wait for a while before sending a ProcessDevice 
message to the follow ups. 

=cut

sub process_buffer
{
	my($self) = @_;
	Logger->debug("Processing buffer entries");
	my $delay = $self->config->section("cmdb::process::syslog::delay_forward");
	my @followUp = split(/\,/, $self->config->section("cmdb::process::syslog::follow_up"));
	my $action = 'ProcessDevice';
	
	foreach my $device_id ( keys %deviceBuffer )
	{
		if ( time() - $deviceBuffer{ $device_id } >= $delay )
		{
			
			my $device = ActiveCMDB::Object::Device->new( device_id => $device_id);
			$device->find();
			$self->store_object('device', $device);
			foreach my $ep_name (@followUp)
			{
				my $ep = ActiveCMDB::Object::Endpoint->new(name => $ep_name);
				
				$ep->get_data();
				my $message = ActiveCMDB::Object::Message->new();
				$message->from($self->process->name);
				$message->to( $ep->dest_in );
				$message->subject( $action );
				$message->payload( $ep->subjects->{$action}->parse( $self->object_store ) );
				$self->broker->sendframe($message, {});
			} 
			delete $deviceBuffer{$device_id};
		}
	}
	
	$self->set_buffertime();
}

=head2 import_expressions

Import all regular expression from the expfile.

=cut

sub import_expressions
{
	my($self) = @_;
	Logger->debug("Importing new expressions");
	my $expr_file = subst_envvar( $self->config->section("cmdb::process::syslog::expfile") );
	
	if ( -f $expr_file )
	{
		$self->expr_clear;
		my $fh = undef;
		open($fh, "<", $expr_file);
		while ( <$fh> )
		{
			chomp;
			$self->expr_add($_);
		}
		close($fh);
		Logger->info("Loaded " . $self->expr_count . " expression(s)");
	}
}

=head2 set_buffertime

Method set_buffertime sets the buffer_time attribute to the lowest value
of the %deviceBuffer hash.

=cut

sub set_buffertime
{
	my($self) = @_;
	foreach (keys %deviceBuffer) {
		if ( $deviceBuffer{$_} < $self->buffer_time && $deviceBuffer{$_} > 0 ) {
			$self->buffer_time($deviceBuffer{$_});
		}
	}
}

=head2 handle_signals

Method handle_signals is the signal handler. The server stops at either an INT or TERM signal

=cut

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

1;