package ActiveCMDB::Object::Process;

=begin nd

    Script: ActiveCMDB::Object::Process.pm
    ___________________________________________________________________________

    Version 1.0

    Copyright (C) 2011-2015 Theo Bot

    http://www.activecmdb.org


    Topic: Purpose

    ActiveCMDB::Object::Process class definition

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
	
	Object to hold process information for the process manager
	
	
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

has 'instance'		=> ( is => 'ro', isa => 'Int' );
has 'name'			=> ( is => 'ro', isa => 'Str' );
has 'path'			=> ( is => 'rw', isa => 'Str|Undef' );
has 'type'			=> ( is => 'rw', isa => 'Str|Undef' );
has 'pid'			=> ( is => 'rw', isa => 'Int|Undef', default => 0 );
has 'ppid'			=> ( is => 'rw', isa => 'Int|Undef', default => 0 );
has 'exectime'		=> ( is => 'rw', isa => 'Int|Undef', default => 0 );
has 'status'		=> ( is => 'rw', isa => 'Int|Undef' );
has 'server_id'		=> ( is => 'ro', isa => 'Int|Undef' );
has 'running'		=> ( is => 'rw', isa => 'Int|Undef' );
has 'comms'			=> ( is => 'rw', isa => 'Str|Undef' );
has 'activity'		=> ( is => 'rw', isa => 'Any|Undef' );
has 'updated_by'	=> ( is => 'rw', isa => 'Str|Undef' );
has 'updated_at'	=> ( is => 'rw', isa => 'Int|Undef' );
has 'parent'		=> ( is => 'rw', isa => 'Str|Undef' );


has 'coder'			=> ( 
	is => 'rw', 
	isa => 'Object',
	default => sub {
		JSON::XS->new->utf8->pretty->allow_nonref
	} 
);

# Schema
has 'riak'		=> (
	is => 'rw', 
	isa => 'Object', 
	default => sub { 
		$client->bucket('CmdbProcess');		
	} 
);

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

sub process_name {
	my $self = shift;
	
	#Logger->debug("Process name: ".$self->name . '-' . $self->server_id . '-' .$self->instance);
	return $self->name . '-' . $self->server_id . '-' .$self->instance;
}

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

sub action {
	my($self, $data) = @_;
	
	if ( defined($data) ) {
		$self->activity( $data );
		$self->update($self->process_name());
	}
	
	return $self->activity;
}

sub kill {
	my($self) = @_;
	
	Logger->warn("Sending kill to " . $self->pid );
	kill 15, $self->pid;
}

sub exects {
	my($self) = @_;
	my $t = sprintf("%s", DateTime->from_epoch( epoch => $self->exectime || 0 ));
	$t =~ s/T/ /;
	return $t;
}

sub updatets {
	my($self) = @_;
	
	my $t = sprintf("%s", DateTime->from_epoch( epoch => $self->updated_at || 0 ));
	$t =~ s/T/ /;
	return $t;
}
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