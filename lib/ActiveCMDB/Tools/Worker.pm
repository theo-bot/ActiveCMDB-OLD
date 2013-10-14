use utf8;
package ActiveCMDB::Tools::Worker;

=head1 MODULE - ActiveCMDB::Tools::Worker
    ___________________________________________________________________________

=head1 VERSION

    Version 1.0

=head1 COPYRIGHT

    Copyright (C) 2011-2015 Theo Bot

    http://www.activecmdb.org


=head1 DESCRIPTION

    This is the actual job processor

=head1 LICENSE

    This program is free software; you can redistribute it and/or
    modify it under the terms of the GNU General Public License
    as published by the Free Software Foundation; either version 2
    of the License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

=cut


=head1 IMPORTS

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
=cut

use Moose;
use Logger;
use Switch;
use DateTime;
use Try::Tiny;
use ActiveCMDB::Object::Process;
use ActiveCMDB::Tools::Common;
use ActiveCMDB::ConfigFactory;
use ActiveCMDB::Common::Broker;
use ActiveCMDB::Common::Constants;
use ActiveCMDB::Common::Import;
use ActiveCMDB::Model::CMDBv1;
use Data::Dumper;
use Carp qw(cluck);

with 'ActiveCMDB::Tools::Common';

=head1 ATTRIBUTES

=head2 disco

=cut

has 'worker' 	=> (is => 'rw', isa => 'Hash' );
use constant CMDB_PROCESSTYPE => 'worker';

no strict 'refs';

=head1 METHODS

=head2 init

Initialize discovery processor
 - Import configuration
 - Initialize internal process administration
 - Discover interrogations
 - Load device classes
 - Connect to the data warehouse
 - Connect to broker
 - Deamonize
  
 Arguments:
 $self		- Reference to discovery object
 $args		- Hash reference
 				{instance} - process instance
 				
=cut

sub init {
	my($self, $args) = @_;
	
	Logger->info("Initializing job processor");
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

=head2

Process message from the queue

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
			switch( $msg->subject )
			{
				case 'StartJob'			{ $self->handle_job($msg); }
				case 'Shutdown'			{ $self->process->status(PROC_SHUTDOWN) }
				else					{ Logger->warn("Undefined message type ".$msg->subject )}
			}
			$delay--;
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

=head2 handle_job


=cut

sub handle_job
{
	my($self, $msg) = @_;
	my $result;
	my $job = $msg->payload->{job};
	Logger->info("Handling job muid " . $msg->muid);
	Logger->debug(Dumper($job));
	switch ( $job->{Type} )
	{
		case 'Import' 		{ $result = cmdb_import_start({ id => $job->{id} }) }
	}
}


=head2 handle_signals

Worker process specific signal handler

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