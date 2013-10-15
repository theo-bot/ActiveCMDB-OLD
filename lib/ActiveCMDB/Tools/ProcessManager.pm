use utf8;
package ActiveCMDB::Tools::ProcessManager;
=head1 MODULE - ActiveCMDB::Tools::ProcessManager
    ___________________________________________________________________________

=head1 VERSION

    Version 1.0

=head1 COPYRIGHT

    Copyright (C) 2011-2015 Theo Bot

    http://www.activecmdb.org


=head1 DESCRIPTION

    Module to handle process management

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
 use POSIX qw(:sys_wait_h :signal_h);
 use ActiveCMDB::ConfigFactory;
 use ActiveCMDB::Tools::Common;
 use ActiveCMDB::Model::CMDBv1;
 use ActiveCMDB::Common::Broker;
 use ActiveCMDB::Common::Constants;
 use ActiveCMDB::Object::Process;
 use ActiveCMDB::Common::Database;
 use ActiveCMDB::Schema;
 use Logger;
 use Switch;
 use Data::Dumper;
=cut

use Moose;
use POSIX qw(:sys_wait_h :signal_h);
use ActiveCMDB::ConfigFactory;
use ActiveCMDB::Tools::Common;
use ActiveCMDB::Model::CMDBv1;
use ActiveCMDB::Common::Broker;
use ActiveCMDB::Common::Constants;
use ActiveCMDB::Object::Process;
use ActiveCMDB::Common::Database;
use ActiveCMDB::Schema;
use Logger;
use Switch;
use Data::Dumper;

with 'ActiveCMDB::Tools::Common';

use constant CMDB_PROCESSTYPE => 'process';
use constant CMDB_INSTANCE    => 0;

=head1 METHODS

=head2 init

Initialize process manager

=cut

sub init {
	my($self, $args) = @_;
	my($name);
	
	$self->{signal_raised} = false;
	
	Logger->info("Starting process manager");

	$self->config(ActiveCMDB::ConfigFactory->instance());
	$self->config->load('cmdb');
	my $config = $self->config->section('cmdb::default');
	
	
	Logger->debug("Setting process type " . CMDB_PROCESSTYPE);
	$self->process(ActiveCMDB::Object::Process->new(
			name		=> CMDB_PROCESSTYPE,
			server_id	=> $config->{server_id},
			instance	=> $args->{instance} || CMDB_INSTANCE
		)	
	);
	$name = $self->process->process_name();
	$self->process->type(CMDB_PROCESSTYPE);
	$self->process->pid($$);
	$self->process->status(PROC_RUNNING);
	$self->process->exectime(time());
	$self->process->path($0);
	$self->process->ppid(getppid());
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
	
	$self->start_childern();
	
}

=head2 start_childern
Start managed processes. 
=cut

sub start_childern {
	my($self) = @_;
	
	# Procdata is the process configuration data
	$self->{procdata} = $self->config->section("cmdb::process");
	
	# Procinfo will containt process objects
	$self->{procinfo} = undef;
	
	foreach my $proc (keys $self->{procdata})
	{
		
		if ( !defined($self->{procdata}->{$proc}->{maxproc}) ) {
			$self->{procdata}->{$proc}->{maxproc} = $self->config->section("cmdb::default::maxproc");
		}
		if ( $self->{procdata}->{$proc}->{managed} ) {
			Logger->info("Starting " . $self->{procdata}->{$proc}->{maxproc} . " instances of $proc");
			for (my $i=1; $i <= $self->{procdata}->{$proc}->{maxproc}; $i++)
			{
				$self->{procinfo}->{$proc}->{$i} = ActiveCMDB::Object::Process->new(
						instance	=> $i,
						name		=> $proc,
						server_id	=> $self->config->section("cmdb::default::server_id")
				);
				
				$self->{procinfo}->{$proc}->{$i}->type($proc);
				$self->{procinfo}->{$proc}->{$i}->path($self->{procdata}->{$proc}->{path});
				$self->{procinfo}->{$proc}->{$i}->parent($self->process->process_name());
				my $pid = $self->{procinfo}->{$proc}->{$i}->start();
				if ( defined($pid) && $pid > 0) {
					$self->{procinfo}->{pid}->{$pid}->{type} = $proc;
					$self->{procinfo}->{pid}->{$pid}->{instance} = $i;
				}
				$self->{procinfo}->{$proc}->{$i}->ppid($$);
				$self->{procinfo}->{$proc}->{$i}->update($self->process->process_name());
			}
		}
	}
	
}

=head2 procs

Return the managed processes structure

=cut

sub procs {
	my $self = shift;
	
	return $self->{procs}
}

=head2 manage

Main processing loop.
 
 - Check for any raised signals
 - Check for frames at the broker
 

=cut

sub manage {
	my($self) = @_;
	
	my($msg, $delay);
	
	while ( $self->process->status != PROC_SHUTDOWN ) {
		$delay = 5;
		
		
		if ( $self->raise_signal )
		{
			$self->handle_signals();
			next;
		}
		
		#
		# Check if there is a message at the broker
		#
		$msg = $self->broker->getframe({ process_type => $self->process->type });

		if ( defined($msg) && $msg ) {
			switch ( $msg->subject )
			{
				case 'Shutdown'			{ $self->proc_shutdown($msg->payload); }
				else					{ Logger->warn("Undefined message type \n". Dumper($msg) )}	
			}
			
			$delay--;
		}
		
		sleep $delay;
	}
	
	$self->killall();
	
}

=head2 proc_shutdown

Kill all managed processes and set status to shutdown

=cut

sub proc_shutdown {
	my($self, $proc_name) = @_;
	Logger->warn("Received shutdown message for $proc_name");
	
	if ( $proc_name eq $self->process->process_name() )
	{
		$self->process->status(PROC_SHUTDOWN);
		$self->process->update($self->process->process_name);
	} else {
		my @p = split(/\-/, $proc_name);
		$self->{procinfo}->{$p[0]}->{$p[2]}->get_data();
		$self->{procinfo}->{$p[0]}->{$p[2]}->kill();
	}
}

=head2 handle_signals

Process manager specfic signal handler

=cut

sub handle_signals
{
	my($self) = @_;
	Logger->warn("Handling signal flags");
	foreach my $sig (keys $self->{signal})
	{
		Logger->debug("Processing signal $sig");
		switch ($sig)
		{
			case 'INT'		{ 	$self->process->status(PROC_SHUTDOWN);  }
			case 'TERM'		{   $self->process->status(PROC_SHUTDOWN);	}
			case 'CHLD'		{ $self->reaper(); }
		}
	}
	$self->reset_signal();
}

=head2 reaper

Reap dead processes and start them again if required.

=cut

sub reaper {
	my($self) = @_;
	my($pid);
	
	#
	# Resetting signal flag
	#
	$self->{signal}->{CHLD} = false;
	
	Logger->debug("Reaping process");
	
	while (( $pid = waitpid(-1, WNOHANG)) > 0 )
	{
		Logger->debug("Reaped $pid");
		if ( defined($self->{procinfo}->{pid}->{$pid}) )
		{
			my $i = $self->{procinfo}->{pid}->{$pid}->{instance};
			my $t = $self->{procinfo}->{pid}->{$pid}->{type};
			$self->{procinfo}->{$t}->{$i}->get_data();
			$self->{procinfo}->{pid}->{$pid} = undef;
			if ( $self->{procinfo}->{$t}->{$i}->status != PROC_DISABLED )
			{
				my $newpid = $self->{procinfo}->{$t}->{$i}->start();
				if ( defined($newpid) && $newpid > 0) {
					$self->{procinfo}->{pid}->{$newpid}->{type} = $t;
					$self->{procinfo}->{pid}->{$newpid}->{instance} = $i;
				}
			}
			
		} else {
			Logger->warn("Process id $pid not in administration");
		}
	}
}

=head2 killall

Kill all managed processes.

=cut

sub killall {
	my($self) = @_;
	Logger->warn("Killing all child processes");
	foreach my $pid (keys $self->{procinfo}->{pid} ) {
		kill SIGINT, $pid;
	} 
}

1;