package ActiveCMDB::Tool::SyslogServer;

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
use constant CMDB_PROCESSTYPE => 'syslog';
use ActiveCMDB::Tools::Common;
use ActiveCMDB::ConfigFactory;
use ActiveCMDB::Common::Broker;
use ActiveCMDB::Common::Constants;
use ActiveCMDB::Model::CMDBv1;
use ActiveCMDB::Schema;

has 'server'	=> (
	is		=> 'rw',
	isa		=> 'Object',
);

with 'ActiveCMDB::Tools::Common';

sub init 
{
	my($self, $args) = @_;
	
	Logger->info("Starting ip syslog manager");
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
	
	#
	# Initialize server
	#
	$self->server( Net::Syslogd->new( 
								LocalPort => $self->config->section('cmdb::process::syslog::port'),
								timeout   => $self->config->section('cmdb::process::syslog::timeout')  
							) 
				);
}


sub manage
{
	my($self) = @_;
	
	
	while ( $self->process->status != PROC_SHUTDOWN )
	{
		
		#
		# Handle raised signals
		#
		if ( $self->raise_signal == true ) {
			Logger->debug("Seems a signal has been raised");
			$self->handle_signals();
			$self->raise_signal(false);
			next;
		}
		
		
	}
}