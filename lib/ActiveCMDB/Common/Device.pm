package ActiveCMDB::Common::Device;
=head1 MODULE - ActiveCMDB::Common::Device
    ___________________________________________________________________________

=head1 VERSION

    Version 1.0

=head1 COPYRIGHT

    Copyright (C) 2011-2015 Theo Bot

    http://www.activecmdb.org


=head1 DESCRIPTION

    Common device operations

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

#########################################################################
# Initialize  modules
=head1 IMPORTS
 use Exporter;
 use Logger;
 use ActiveCMDB::Model::CMDBv1;
 use Try::Tiny;
 use strict;
 use Socket;
=cut

use Exporter;
use Data::Dumper;
use Logger;
use ActiveCMDB::Model::CMDBv1;
use ActiveCMDB::Object::ipAdEntry;
use Try::Tiny;
use strict;
use Socket;

our @ISA = ('Exporter');

our @EXPORT = qw(
	cmdb_get_host_by_ip
	cmdb_gethostByAddr
	cmdb_get_host_by_name
	get_vlans_by_device
	get_vrfs_by_device
	get_networks_by_interface
	get_dlci_by_device
);

=head1 FUNCTIONS

=head2 cmdb_get_host_by_ip

Get an ip device's hostname via it's netowrk adres

 Arguments:
 $ip		- String containing a network address
 
 Returns:
 $hostname	- String containing a device hostname

=cut

sub cmdb_get_host_by_ip
{
	my($ip) = @_;
	my($schema,$rs, $row, $hostname, $tally);
	
	$hostname = $ip;
	#
	# Connect to database
	#
	$schema = ActiveCMDB::Model::CMDBv1->instance();
	
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

=head2 cmdb_gethostByAddr

Get an ip device's hostname via it's netowrk adres

 Arguments:
 $ip		- String containing a network address
 
 Returns:
 $device	- ActiveCMDB::Object::Device object
 
=cut

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
	$schema = ActiveCMDB::Model::CMDBv1->instance();
	
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

sub cmdb_get_host_by_name
{
	my($hostname) = @_;
	my ($device_id,$device,$schema,$rs,$row);
	
	$device_id = undef;
	$device    = undef;
	
	#
	# Connect to database
	#
	$schema = ActiveCMDB::Model::CMDBv1->instance();
	
	$rs =$schema->resultset("IpDevice")->search({ hostname => $hostname });
	if ( $rs->count > 0 )
	{
		$row = $rs->next;
		$device_id = $row->device_id;
		Logger->debug("Found device_id " . $row->device_id );
	}
	
	if ( defined($device_id) )
	{
		$device = ActiveCMDB::Object::Device->new(device_id => $device_id );
		$device->get_data();
	} else {
		Logger->warn("Device ID not set.");
	}
	
	return $device;
}

sub get_vlans_by_device
{
	my($device_id) = @_;
	my $vlans = undef;
	Logger->info("Fetching vlan data");
	if ( defined($device_id) && $device_id > 0 )
	{
		my($schema,$rs,$row);
		#
		# Connect to database
		#
		$schema = ActiveCMDB::Model::CMDBv1->instance();
	
		$rs = $schema->resultset('IpDeviceVlan')->search(
			{
				device_id => $device_id
			},
			{
				columns		=> [qw/vlan_id/],
				order_by	=> { -asc => 'vlan_id' }
			}
		);
		
		if ( defined($rs) ) 
		{
			while ( $row = $rs->next )
			{
				$vlans->{$row->vlan_id}->{name} = 'VLan ' . $row->vlan_id;
				$vlans->{$row->vlan_id}->{vlan_id} = $row->vlan_id;
			}
			Logger->debug(Dumper($vlans));
		} else {
			Logger->info("Vlan Resulset not defined");
		}
	} else {
		Logger->warn("Device ID not set");
	}
	
	return $vlans
}

sub get_vrfs_by_device
{
	my($device_id) = @_;
	my $vrfs = undef;
	Logger->info("Fetching vrf data");
	if ( defined($device_id) && $device_id > 0 )
	{
		my($schema,$rs,$row);
		#
		# Connect to database
		#
		$schema = ActiveCMDB::Model::CMDBv1->instance();
	
		$rs = $schema->resultset('IpDeviceVrf')->search(
			{
				device_id => $device_id
			},
			{
				columns		=> [qw/vrf_rd vrf_name/],
				distinct	=> 1
			}
		);
		
		if ( defined($rs) ) 
		{
			Logger->info("Found " . $rs->count . " vpns for device");
			while ( $row = $rs->next )
			{
				$vrfs->{$row->vrf_rd}->{vrf_name} = $row->vrf_name;
				$vrfs->{$row->vrf_rd}->{vrf_rd} = $row->vrf_rd;
			}
			Logger->debug(Dumper($vrfs));
		} else {
			Logger->info("VRF Resulset not defined");
		}
	} else {
		Logger->warn("Device ID not set");
	}
	
	return $vrfs
}

sub get_dlci_by_device
{
	my($device_id) = @_;
	my $circuits = undef;
	if ( defined($device_id) && $device_id > 0 )
	{
		my($schema,$rs,$row);
		#
		# Connect to database
		#
		$schema = ActiveCMDB::Model::CMDBv1->instance();
		
		$rs = $schema->resultset("IpDeviceIntDlci")->search(
				{
					device_id => $device_id
				},
				{
					order_by	=> 'dlci'
				}
		);
		
		if ( defined($rs) )
		{
			Logger->info("Found " . $rs->count . " frame-relay circuits for device");
			while ( $row = $rs->next )
			{
				$circuits->{$row->dlci.'-'.$row->ifIndex}->{dlci} = $row->dlci;
				$circuits->{$row->dlci.'-'.$row->ifIndex}->{ifindex} = $row->ifIndex;
			}
		} else {
			Logger->info("No frame-relay circuits configured for device");
		}
	} else {
		Logger->warn("Device ID not set");
	}
	
	return $circuits;
}

sub get_networks_by_interface
{
	my($device_id, $ifindex) = @_;
	my @nets = ();
	
	if ( defined($device_id) && defined($ifindex) )
	{
		my($schema,$rs,$row);
		#
		# Connect to database
		#
		$schema = ActiveCMDB::Model::CMDBv1->instance();
		
		$rs = $schema->resultset("IpDeviceNet")->search(
			{
				device_id		=> $device_id,
				ipadentifindex	=> $ifindex
			}, 
			{
				columns			=> 'ipadentaddr'
			}
		);
		
		if ( defined($rs) )
		{
			while( $row = $rs->next )
			{
				my $net = ActiveCMDB::Object::ipAdEntry->new(device_id => $device_id, ipadentaddr => $row->ipadentaddr );
				$net->get_data();
				push(@nets, $net);
			}
		}
	}
	
	return @nets
}