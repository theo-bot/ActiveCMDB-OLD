package ActiveCMDB::Tools::SyslogServer;

=begin nd

    Script: ActiveCMDB::Tools::SyslogServer.pm
    ___________________________________________________________________________

    Version 1.0

    Copyright (C) 2011-2015 Theo Bot

    http://www.activecmdb.org


    Topic: Purpose

    Syslog server to process config changes

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
use ActiveCMDB::Tools::Common;
use ActiveCMDB::ConfigFactory;
use ActiveCMDB::Common::Broker;
use ActiveCMDB::Common::Constants;
use ActiveCMDB::Common::Tempfile;
use ActiveCMDB::Common::Device;
use ActiveCMDB::Model::CMDBv1;
use ActiveCMDB::Schema;

use constant CMDB_PROCESSTYPE => 'syslog';

has 'server'	=> (
	is		=> 'rw',
	isa		=> 'Maybe[Object]',
);

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

has 'expr_age'	=> (
	is		=> 'rw',
	isa		=> 'Int',
	default	=> 0
);

my %deviceBuffer;


with 'ActiveCMDB::Tools::Common';

sub init 
{
	my($self, $args) = @_;
	
	Logger->info("Starting ip syslog manager");
	$self->config(ActiveCMDB::ConfigFactory->instance());
	$self->config->load('cmdb');
	$self->process( ActiveCMDB::Object::Process->new(
			name		=> CMDB_PROCESSTYPE,
			type		=> CMDB_PROCESSTYPE,
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
	
	#
	# Connecting to database
	#
	#$self->schema(ActiveCMDB::Schema->connect(ActiveCMDB::Model::CMDBv1->config()->{connect_info}));
	
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
}


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
				$deviceBuffer{ $message->remoteaddr } = time();
			}
		}
	}
}

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