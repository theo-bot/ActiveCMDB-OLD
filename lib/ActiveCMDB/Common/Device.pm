package ActiveCMDB::Common::Device;

=begin nd

    Script: ActiveCMDB::Common::Device.pm
    ___________________________________________________________________________

    Version 1.0

    Copyright (C) 2011-2015 Theo Bot

    http://www.activecmdb.org


    Topic: Purpose

    Common device operations

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
	
	
	
	
=cut

#########################################################################
# Initialize  modules
use Exporter;
use Logger;
use ActiveCMDB::Model::CMDBv1;
use ActiveCMDB::Schema;
use Try::Tiny;
use strict;
use Socket;

our @ISA = ('Exporter');

our @EXPORT = qw(
	cmdb_get_host_by_ip
	cmdb_gethostByAddr
);
#########################################################################
# Routines

sub cmdb_get_host_by_ip
{
	my($ip) = @_;
	my($schema,$rs, $row, $hostname, $tally);
	
	$hostname = $ip;
	#
	# Connect to database
	#
	$schema = ActiveCMDB::Schema->connect(ActiveCMDB::Model::CMDBv1->config()->{connect_info});
	
	$tally = $schema->resultset("IpDevice")->search({ mgtaddress => $ip })->count;
	if ( $tally > 0 )
	{
		$rs = $schema->resultset("IpDevice")->search({ mgtaddress => $ip });
		$row = $rs->next;
		$hostname = $row->hostname;
	}
	
	if ( $hostname eq $ip )
	{
		$tally = $schema->resultset("IpDeviceNet")->search({ ipadentaddr => $ip })->count;
		if ( $tally > 0 )
		{
			$rs = $schema->resultset("IpDeviceNet")->search(
				{
					"me.ipadentaddr" => $ip
				},
				{
					join 		=> 'ip_device',
					'+select'	=> ['ip_device.hostname'],
					'+as'		=> ['hostname']
				}
			);
			
			$row = $rs->next;
			$hostname = $row->get_column("hostname");
		}
	}
	
	if ( $hostname == $ip )
	{
		my $name = gethostbyaddr(inet_aton($ip), AF_INET);
		if ( defined($name) && length($name) > 2 ) {
			$hostname = $name
		}
	}
	
	return $hostname;
}

sub cmdb_gethostByAddr
{
	my($ip) = @_;
	my($schema,$rs, $row, $hostname, $tally, $device_id, $device);
	
	$device_id = undef;
	$device    = undef;
	$hostname  = $ip;
	#
	# Connect to database
	#
	$schema = ActiveCMDB::Schema->connect(ActiveCMDB::Model::CMDBv1->config()->{connect_info});
	
	$tally = $schema->resultset("IpDevice")->search({ mgtaddress => $ip })->count;
	if ( $tally > 0 )
	{
		$rs = $schema->resultset("IpDevice")->search({ mgtaddress => $ip });
		$row = $rs->next;
		$hostname = $row->hostname;
		$device_id = $row->device_id;
	}
	
	if ( $hostname eq $ip )
	{
		$tally = $schema->resultset("IpDeviceNet")->search({ ipadentaddr => $ip })->count;
		if ( $tally > 0 )
		{
			$rs = $schema->resultset("IpDeviceNet")->search(
				{
					"me.ipadentaddr" => $ip
				},
				{
					join 		=> 'ip_device',
					'+select'	=> ['ip_device.hostname', 'ip_device.device_id'],
					'+as'		=> ['hostname', 'device_id']
				}
			);
			
			$row = $rs->next;
			$hostname = $row->get_column("hostname");
			$device_id = $row->get_column("device_id");
		}
	}
	
	if ( defined($device_id) )
	{
		$device = ActiveCMDB::Object::Device->new(device_id => $device_id );
		$device->get_data();
	}
	
	return $device;
}
