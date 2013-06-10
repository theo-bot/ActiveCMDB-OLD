use utf8;
package ActiveCMDB::Tools::ConfigFetcher;

=begin nd

    Script: ActiveCMDB::Tools::ConfigFetcher.pm
    ___________________________________________________________________________

    Version 1.0

    Copyright (C) 2012-2013 Theo Bot

    http://www.activecmdb.org


    Topic: Purpose

    ActiveCMDB::Tools::ConfigFetcher class definition

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
	
	This is the actual configuration fetch engine
	
	
=cut

#
# Initialize modules
#
use 5.16.0;
use Moose;
use Digest::MD5;
use Socket;
use Sys::Hostname;
use Logger;
use Switch;
use File::Basename;

use ActiveCMDB::ConfigFactory;
use ActiveCMDB::Common::Broker;
use ActiveCMDB::Common::Constants;
use ActiveCMDB::Model::CMDBv1;
use ActiveCMDB::Schema;
use ActiveCMDB::Object::Configuration;
use Data::Dumper;

with 'ActiveCMDB::Tools::Common';

#
# Attributes
#
has 'servername'		=> (is => 'rw', isa => 'Str');
has 'landing'		=> (is => 'rw', isa => 'HashRef');


#
# Constants
#
use constant CMDB_PROCESSTYPE => 'config';

=item init

Initialize config fetcher

=cut

sub init {
	my($self, $args) = @_;
	
	Logger->info("Initializing config fetcher");
	$self->{signal_raised} = false;
	$self->config(ActiveCMDB::ConfigFactory->instance());
	$self->config->load('cmdb');
	$self->process( ActiveCMDB::Object::Process->new(
			name		=> CMDB_PROCESSTYPE,
			instance	=> $args->{instance},
			server_id	=> $self->config->section('cmdb::default::server_id')
		)
	);
	$self->process->type(CMDB_PROCESSTYPE);
	$self->process->status(PROC_RUNNING);
	$self->process->pid($$);
	$self->process->update();
	
	#
	# Loading device classes
	#
	$self->class_loader();
	
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
	# Initialize landing zone
	#
	my $data = undef;
	foreach my $landing (split(/\,/, $self->config->section('cmdb::process::config::landing_zone') ) )
	{
		next unless ( $landing =~ /^(.+):(.+)/ );
		next unless ( $1 eq hostname );
		$data->{hostname}  = $1;
		$data->{directory} = $2;
		
		foreach my $a ( $self->lookup($data->{hostname}) )
		{
			if ( $a !~ /^127\..+/ ) {
				$data->{netaddr} = $a;
				last;
			}
		}
		$self->landing($data);
		last;
	}
	
	#
	# Disconnect fromn tty and start new session
	#
	$self->disconnect();
}

=item process

Process messages to discover devices

=cut

sub process
{
	my($self) = @_;
	my($msg, $delay);
	
	while ( $self->running != PROC_SHUTDOWN )
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
		$msg = $self->broker->getframe({ process_type => $self->process_type });
		if ( $msg ) {
			
			switch ( $msg->subject )
			{
				case 'ProcessDevice'	{ $self->process_device($msg) }
				case 'Shutdown'			{ $self->running(PROC_SHUTDOWN) }
				else					{ Logger->warn("Undefined message type ".$msg->subject )}
			}
			$delay--;
			
			Logger->debug("Message processed");
		}
		
		#
		# Make sure we don't start using too much cpu
		#
		if ( $delay > 0 ) {
			sleep $delay;
		}
	}	
}

sub process_device
{
	my($self, $msg) = @_;
	my($device, $cycles, $result);
	
	if ( defined($msg->payload) )
	{
		Logger->info("Processing order ".$msg->cid . " device_id ". $msg->payload->{device}->{device_id});
		
		$device = Class::Device->new( device_id => $msg->payload->{device}->{device_id} );
		$device->get_data();
		
		my $device_class = $self->get_class_by_oid($device->attr->sysobjectid);
		if ( $device_class ne 'Class::Device' ) {
				Logger->debug("Switch device class to $device_class");
				#
				# Create device specific object
				#
				$device = $device_class->new(device_id => $device->device_id);
				$device->get_data();
				$self->process->action("Fetching config for " . $device->hostname );
		}
		
		my %fetchers = ();
		%fetchers = $self->fetchers($device_class, %fetchers);
		
		$cycles = 0;
		foreach (keys %fetchers) {
			if ( $fetchers{$_} > $cycles ) { $cycles = $fetchers{$_}; }
		}
		
		$result = undef;
		for (my $i = 1; $i <= $cycles; $i++)
		{
			foreach my $method (keys %fetchers)
			{
				if ( $fetchers{$method} == $i )
				{
					#
					# Arguments to method 
					#
					# - $self->landing
					#
					# Result hash:
					# complete	- true/false
					# filenum	- Expected number of files
					# files		- Array with filenames
					# location	- location of the landingspot of the files
					# 
					$result = $device->$method($self->landing);
					Logger->debug( Dumper($result) );
					if ( defined($result) && $result->{complete} )
					{
						$self->store_config($result, $device);
						$i = $cycles + 1;
						last;
					}
					
				}
			}
			# End foreach
		}
		# End for
		
	}
}


=item fetchers

Search recusive for fetchers in .class files:

fetchers {
					NetConfig   2;
					CopyConfig  1;
			  };
			  
In this case the CopyConfig method will be tested first, followed
by the NetConfig method.

=cut

sub fetchers
{
	my($self, $class, %fetchers) = @_;
	
	if ( defined($class) && defined($self->{classes}->{$class}) )
	{
		if ( defined( $self->{classes}->{$class}->{fetchers} ) )
		{
			foreach my $key (keys %{$self->{classes}->{$class}->{fetchers}})
			{
				if ( !defined($fetchers{$key}) && $self->{classes}->{$class}->{fetchers}->{$key} >= 1 ) {
					$fetchers{$key} = $self->{classes}->{$class}->{fetchers}->{$key};
				}
			}
		} else {
			Logger->debug("No fetchers for class $class");
		}
		
		if ( defined($self->{classes}->{$class}->{super}) )
		{
			my $super = 'Class::' . $self->{classes}->{$class}->{super};
			if ( defined($self->{classes}->{$super}) )
			{
				%fetchers = $self->fetchers($super, %fetchers);
			}
		}
	}
	
	return %fetchers;
}

=item store_config

Store config in the database. 

Arguments:
$cfgdata	- Anonymous hash with results of the download
$device		- Class::Device or subtype 

Procedure:
1. Calculate checksum of the file
2. Verify checksum in database
3. If not present, add it to the database


=cut

sub store_config
{
	my($self, $cfgdata, $device) = @_;
	my($sum, $count);
	
	$sum = "";
	$count = 0;
	
	foreach my $f ( @{$cfgdata->{files}} )
	{
		my $file = $f->{filename};
		#try {
    		open(FILE, $file); # or die ("Unable to open file $file. " . $!);
    		binmode(FILE);

    		$sum  = Digest::MD5->new->addfile(*FILE)->hexdigest;
    		close(FILE);
    		
    		
		#} catch {
		#	Logger->warn("Failed to open $file:");
		#	return false;
		#};
		
		$count = $self->schema->resultset("IpConfigData")->search(
					{
						device_id 	=> $device->device_id,
						config_name	=> basename($file),
						config_checksum	=> $sum
					}
				)->count;
		
		if ( $count == 0 )
		{
			
			my $object = undef;
			
			$object = ActiveCMDB::Object::Configuration->new();
			$object->config_id($self->uuid);
			$object->device_id($device->device_id);
			$object->config_date(time());
			$object->config_status(0);
			$object->config_type($self->_get_filetype($file));
			$object->config_name(basename($file));
			$object->config_checksum($sum);
			$object->config_data( do{
										local $/; 
										open(my $f1, '<', $file);
										my $tmp1 = <$f1>; 
										close $f1 or die $!; 
										$tmp1
									});
			
			my $transaction = sub { $object->save(); };
			
			$self->schema->txn_do( $transaction );
			
		} else {
			Logger->info("Configuration already in store");
		}
		
		# Unlink the landed file
		#
		if ( -f $file )
		{
			unlink($file);
			Logger->debug("Removed $file from landing zone");
		} else {
			Logger->warn("No file to unlink for $file");
		}	
	}
}

sub _get_filetype
{
	my($self, $file) = @_;
	if ( -B $file ) {
		return 'BINARY';
	} else {
		return 'ASCII';
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
			case 'INT'		{ $self->status(PROC_SHUTDOWN); }
			case 'TERM'		{ $self->status(PROC_SHUTDOWN); }
		}
	}
}

1;