package ActiveCMDB::Object::Process;
=head1 MODULE - ActiveCMDB::Object::Process
    ___________________________________________________________________________

=head1 VERSION

    Version 1.0

=head1 COPYRIGHT

    Copyright (C) 2011-2015 Theo Bot

    http://www.activecmdb.org


=head1 DESCRIPTION

    ActiveCMDB::Object::Process class definition
    Object to hold process information for the process manager

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

 use ActiveCMDB::Common;
 use ActiveCMDB::Common::Constants;
 use Try::Tiny;
 use Logger;
 use Moose;
 use POSIX qw(setsid);
 use Net::Riak;
 use JSON::XS;
 use Data::Dumper;
=cut

use ActiveCMDB::Common;
use ActiveCMDB::Common::Constants;
use Try::Tiny;
use Logger;
use Moose;
use POSIX qw(setsid);
use Net::Riak;
use JSON::XS;
use Data::Dumper;

#
# Create an intance of the global config
#
my $config = ActiveCMDB::ConfigFactory->instance();
$config->load('cmdb');


my $client = Net::Riak->new(
				host		=> $config->section('cmdb::cloud::host'),
				ua_timeout	=> $config->section('cmdb::cloud::timeout')
			); 

my %map = (
			status		=> 1,
			pid			=> 1,
			type		=> 1,
			path		=> 1,
			comms		=> 1,
			activity	=> 1,
			ppid		=> 1,
			exectime	=> 1,
			server_id	=> 1,
			updated_by	=> 1,
			updated_at	=> 1,
			name		=> 1,
			parent		=> 1,
			instance	=> 1
		);

=head1 ATTRIBUTES

=head2 instance

Integer number representing the nth instance of that type of process 
on that server.
=cut
has 'instance'		=> ( is => 'ro', isa => 'Int' );

=head2 name

String name of the process
=cut
has 'name'			=> ( is => 'ro', isa => 'Str' );

=head2 path

String, full pathname of the process to be executed
=cut
has 'path'			=> ( is => 'rw', isa => 'Str|Undef' );

=head2 type

String, type of the process, derrived from cmdb.yml process section
=cut
has 'type'			=> ( is => 'rw', isa => 'Str|Undef' );

=head2 pid

String, process identifier in the Linux process table.
=cut
has 'pid'			=> ( is => 'rw', isa => 'Int|Undef', default => 0 );

=head2 ppid

Integer, parent process identifier in the Linux process table
=cut
has 'ppid'			=> ( is => 'rw', isa => 'Int|Undef', default => 0 );

=head2 exectime

Integer, representing the unixtime that the process was started 
=cut
has 'exectime'		=> ( is => 'rw', isa => 'Int|Undef', default => 0 );

=head2 status

Integer, set to the status of the current process. See also
ActiveCMDB::Common::Constants
=cut
has 'status'		=> ( is => 'rw', isa => 'Int|Undef' );

=head2 server_id

Integer of the server_id derrived from the cmdb.yml file. 
=cut
has 'server_id'		=> ( is => 'ro', isa => 'Int|Undef' );

=head2 running

Integer 
=cut
has 'running'		=> ( is => 'rw', isa => 'Int|Undef' );
has 'comms'			=> ( is => 'rw', isa => 'Str|Undef' );

=head2 activity

String, description of the current activity
=cut
has 'activity'		=> ( is => 'rw', isa => 'Any|Undef' );

=head2 updated_by

String containg the name of the entity that updated the process data
=cut
has 'updated_by'	=> ( is => 'rw', isa => 'Str|Undef' );

=head2 updated_at

Unix timestamp that the process data was updated
=cut
has 'updated_at'	=> ( is => 'rw', isa => 'Int|Undef' );

=head2 parent

Processname of the parent process
=cut
has 'parent'		=> ( is => 'rw', isa => 'Str|Undef' );

=head2 coder

JSON::XS coder object. Allows to encode/decode hash references to
JSON data and reverse 
=cut
has 'coder'			=> ( 
	is => 'rw', 
	isa => 'Object',
	default => sub {
		JSON::XS->new->utf8->pretty->allow_nonref
	} 
);

=head2 riak

Bucket in distributes storage. Process data is stored in distributed storage
=cut
has 'riak'		=> (
	is => 'rw', 
	isa => 'Object', 
	default => sub { 
		$client->bucket('CmdbProcess');		
	} 
);

=head1 METHODS

=head2 start

Start a managed process.
=cut

sub start {
	my($self) = @_;
	my($result, $pid);
	$result = false;
	
	if ( defined($self->path) ) {
		my $path = subst_envvar($self->path);
		if ( -x $path ) {
			Logger->info("Starting $path");
			if ( time() - $self->exectime <= 5 ) { sleep 5; }
			
			
			if ( $pid = fork )
			{
				# Parent part
				$self->pid($pid);
				$self->exectime(time());
				
				#$self->status(2);
				$result = $pid;
			} else {
				# Child part
				#$logger->logdie("Cannot fork $!") unless defined $pid;
				exec($path, '-instance', $self->instance );
		
			}
			
			
		} else {
			Logger->error("Unable to execute $path");
		}
	}
}

=head2 disconnect

Disconnect process from tty and start a new session
=cut

sub disconnect
{
	my($self) = @_;
	my($logfile);
	
	chdir "/";
	# Disconnect from tty and start new session
	setsid or Logger->fatal("Unable to start a new session");
	
	$logfile = Logger::get_logfile_name();
	
	open(STDOUT, ">>", $logfile) or die "Unable to redirect to logfile";
	open(STDERR, ">&STDOUT") or die "Cannot redirect STRERR to STDOUT";
	select STDOUT; $| = 1;
	
	open(STDIN, "<", "/dev/null");
}

=head2 process_name

Return full process name, including name, sever_id and instance (disco-1-1).
=cut
sub process_name {
	my $self = shift;
	
	#Logger->debug("Process name: ".$self->name . '-' . $self->server_id . '-' .$self->instance);
	return $self->name . '-' . $self->server_id . '-' .$self->instance;
}

=head2 get_data

Fetch data from distributed storage.
=cut
sub get_data {
	my($self) = @_;
	my($rs, $row);
	Logger->debug("Fetching data for " . $self->process_name);
	
	$rs = $self->riak->get($self->process_name);
	
	if ( $rs->exists )
	{
		foreach my $attr (keys %map)
		{
			next if ( $attr =~ /name|server_id|instance|path/ );
			if ( defined($rs->{data}->{$attr}) )
			{
				$self->$attr($rs->{data}->{$attr});
			}
			
		}
		$self->path($config->section("cmdb::process::" . $self->type . "::path"));
		return true;
	}
}

=head2 update

Update process data in distributed software.
=cut
sub update {
	my($self, $user) = @_;
	my($data);
	$data = undef;
	
	$self->updated_by($user);
	$self->updated_at(time());
	
	foreach my $attr ( keys %map )
	{
		$data->{$attr} = $self->$attr();
	}
	$ENV{CMDB_INSTANCE} = sprintf("%s-%d", $self->type, $self->instance);
	
	try {
		my $object = $self->riak->get($self->process_name);
		if ( $object->exists  )
		{
			$object->data( $self->coder->encode($data) );
			$object->store;
		} else {
			$object = $self->riak->new_object($self->process_name, $self->coder->encode($data) );
			$object->store;
		}
		return true;
	} catch {
		Logger->error("Failed to update process status");
	}
}

=head2 action

Update activity data and update it in storage

 Arguments
 $self	- Reference to process object 
 $data	- String containing a description of the current activity
=cut
sub action {
	my($self, $data) = @_;
	
	if ( defined($data) ) {
		$self->activity( $data );
		$self->update($self->process_name());
	}
	
	return $self->activity;
}

=head2 kill

Kill the process itself
=cut
sub kill {
	my($self) = @_;
	
	Logger->warn("Sending kill to " . $self->pid );
	kill 15, $self->pid;
}

=head2 exects

Get human readable starttime of the process
=cut
sub exects {
	my($self) = @_;
	my $t = sprintf("%s", DateTime->from_epoch( epoch => $self->exectime || 0 ));
	$t =~ s/T/ /;
	return $t;
}

=head2 updatets

Get human readable updated_at time of the process
=cut
sub updatets {
	my($self) = @_;
	
	my $t = sprintf("%s", DateTime->from_epoch( epoch => $self->updated_at || 0 ));
	$t =~ s/T/ /;
	return $t;
}

=head2 cleanup

Cleanup/Reset process data
=cut 
sub cleanup {
	my($self) = @_;
	my($row);
	
	$self->pid(0);
	$self->ppid(0);
	$self->status(PROC_SHUTDOWN);
	$self->activity('');
	$self->update();
}

__PACKAGE__->meta->make_immutable;
1;