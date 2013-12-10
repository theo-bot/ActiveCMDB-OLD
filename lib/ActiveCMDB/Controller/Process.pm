package ActiveCMDB::Controller::Process;

=begin nd

    Script: ActiveCMDB::Controller::Process.pm
    ___________________________________________________________________________

    Version 1.0

    Copyright (C) 2011-2015 Theo Bot

    http://www.activecmdb.org


    Topic: Purpose

    Catalyst Controller for process management

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

	
=cut

use namespace::autoclean;
use POSIX;
use Moose;
use Data::Dumper;
use ActiveCMDB::Common;
use ActiveCMDB::Common::Conversion;
use ActiveCMDB::Common::Constants;
use ActiveCMDB::Object::Process;
use ActiveCMDB::Common::Broker;
use ActiveCMDB::Object::Message;
BEGIN { extends 'Catalyst::Controller'; }

my $config = ActiveCMDB::ConfigFactory->instance();
$config->load('cmdb');

=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;
	if ( cmdb_check_role($c,qw/processViewer processAdmin/) )
	{
    	$c->stash->{server_id} = $config->section("cmdb::default::server_id");
    	$c->stash->{template}  = "process/container.tt";
	} else {
		$c->response->redirect($c->uri_for($c->controller('Root')->action_for('noauth')));
	} 
}

sub api :Local {
	my($self, $c) = @_;
	
	if ( defined($c->request->params->{oper}) ) {
		$c->forward($c->request->params->{oper});
	}
}

sub list :Local {
	my($self,$c) = @_;
	if ( cmdb_check_role($c,qw/processViewer processAdmin/) )
	{
		my($json,$rs);
		my @rows = ();
		my $keys = ();
		my @objects = ();
	
		$json = undef;
	
		my $rows	= $c->request->params->{rows} || 10;
		my $page	= $c->request->params->{page} || 1;
		my $order	= $c->request->params->{sidx} || 'domain_id';
		my $asc		= $c->request->params->{sord};
		my $search = "";
		my %procStatus = cmdb_name_set('procStatus');
		#
		# Get keys for the query
		#
		$keys = $c->model("Cloud")->bucket("CmdbProcess")->get_keys;
	
		$json->{records} = scalar(@{$keys});
		if ( $json->{records} > 0 ) {
			$json->{total} = ceil($json->{records} / $rows );
		} else {
			$json->{total} = 0;
		} 
	
		#
		# Get the data
		#
		my @keys = @{ $keys };
		foreach my $key ( @keys )
		{
			$c->log->debug("Fetching key:$key");
			push(@objects, $c->model("Cloud")->get({key => $key})->data);
		}
	
	
		@objects = sort { $a->{$order} cmp $b->{$order} } @objects;
	
		if ( $asc eq 'desc' ) {
			@objects = reverse @objects;
		}
	
		foreach my $object (@objects)
		{
			my $process_start	= sprintf("%s", DateTime->from_epoch( epoch => $object->{exectime} || 0 ));
			$process_start =~ s/T/ /;
			my $last_update		= sprintf("%s", DateTime->from_epoch( epoch => $object->{updated_at} || 0 ));
			$last_update =~ s/T/ /;
		
			push(@rows, { 	id => $object->{name} . '-' . $object->{server_id} . '-'. $object->{instance}, 
							cell => [
										$object->{name},
										$object->{server_id},
										$object->{instance},
										$procStatus{ $object->{status} },
										$object->{activity},
										$process_start,
										$object->{pid},
										$object->{ppid},
										$last_update
									] 
						}
				);
		}
	
		$json->{rows} = [ @rows ];
	
		$c->stash->{json} = $json;
		$c->forward( $c->view('JSON') );
	} else {
		$c->response->redirect($c->uri_for($c->controller('Root')->action_for('noauth')));
	}
}

sub view :Local
{
	my($self, $c) = @_;
	
	if ( cmdb_check_role($c,qw/processViewer processAdmin/) )
	{
		my ($process);
		my %states = ();
		my %s = cmdb_name_set('procStatus');
	
		$states{&PROC_SHUTDOWN} = $s{&PROC_SHUTDOWN};
		$states{&PROC_RUNNING} = $s{&PROC_RUNNING};
	
		my @pn;
		@pn = split(/\-/, $c->request->params->{id});
		$process = ActiveCMDB::Object::Process->new(name => $pn[0], server_id => $pn[1], instance => $pn[2]);
		$process->get_data();
		$c->log->debug(Dumper(%states));
		$c->stash->{process} = $process;
		$c->stash->{states} = \%states;
	
		$c->stash->{template} = "process/view.tt";
	
	} else {
		$c->response->redirect($c->uri_for($c->controller('Root')->action_for('noauth')));
	}
}
sub manage :Local {
	my($self, $c) = @_;
	
	if ( cmdb_check_role($c,qw/processAdmin/) )
	{
		my $update = false;
		my @pn = ();
		my($process, $procState, $pid, $broker, $message);
	
		@pn = split(/\-/, $c->request->params->{name});
		$procState = $c->request->params->{procState};
		$process = ActiveCMDB::Object::Process->new(name => $pn[0], server_id => $pn[1], instance => $pn[2]);
		$process->get_data();
		$c->log->debug("Current state ". $process->status . ". New state $procState");
		if ( $process->status != $procState )
		{
			if ( $process->type eq 'process' && $procState == PROC_RUNNING )
			{
				# Start process from fork
				$update = true;
				my $path = subst_envvar($process->path);
				if ( -x $path ) {
					if ( time() - $process->exectime <= 5 ) { sleep 5; }
					$c->log->info("Starting $path");
					if ( $pid = fork )
					{
						# Parent part
						$process->pid($pid);
						$process->exectime(time());
						$process->update();
						#	$self->status(2);
					
					} else {
						# Child part
						#$logger->logdie("Cannot fork $!") unless defined $pid;
						exec($path);
					}
				} else {
					$c->log->error("File $path is not executeable");
				}
			}
			if ( $procState == PROC_SHUTDOWN )
			{
				# Shutdown the process manager
				$c->log->info("Shutdown process");
				$broker = ActiveCMDB::Common::Broker->new( $config->section('cmdb::broker') );
				$broker->init({ process => 'web'.$$ , subscribe => false });
				$message = ActiveCMDB::Object::Message->new();
				$message->from('web'.$$ );
				$message->subject('Shutdown');
		
				if ( defined( $process->parent ) ) {
					$message->to('cmdb.' . $process->parent() );		
				} else {
					$message->to('cmdb.' . $process->process_name() );
				}
				$message->payload($process->process_name());
				$c->log->debug("Sending message to " . $message->to );
				$broker->sendframe($message);
				$update = true;
			}
		}
	
		if ( !$update ) {
			$c->log->info("No update was required");
		}
	
		$c->response->status(HTTP_OK);
		$c->response->body("done");
	} else {
		$c->response->body("Unauthorized");
		$c->respose->status(HTTP_UNAUTHORIZED);
	}
}

=head1 AUTHOR

Theo Bot

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
