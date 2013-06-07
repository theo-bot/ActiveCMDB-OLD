=begin nd

    Script: Class::Device::Ipmib.pm
    ___________________________________________________________________________

    Version 1.0

    Copyright (C) 2008-2011 Theo Bot

    http://www.activecmdb.org


    Topic: Purpose

    CMDB::Device::Arp class definition

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

#########################################################################
# Initialize package
package Class::Device::Ipmib;

use Moose::Role;
use Try::Tiny;
use ActiveCMDB::Common::Constants;
use ActiveCMDB::Object::ipAdEntry;
use Logger;
use Data::Dumper;

my(%ipAddrEntry);

%ipAddrEntry = (
			ipAdEntIfIndex	=> 1,
			ipAdEntAddr		=> 1,
			ipAdEntNetMask	=> 1,
	);


sub discover_ipmib
{
	my($self, $data) = @_;
	my($snmp_oid,$oid, $res1,$res2);
	
	my %ipAdEntAddr = ();
	my $ipAddrTable = undef;
	
	#
	# First collect ip v4 addresses
	#
	$snmp_oid = $self->get_oid_by_name('ipAdEntAddr');
	$res1 = $self->snmp_table($snmp_oid);
	if ( defined($res1) ) 
	{
		
		foreach $oid (keys %$res1)
		{
			my $ip = $res1->{$oid};
			$ipAddrTable->{$ip} = ActiveCMDB::Object::ipAdEntry->new(device_id => $self->device_id, ipadentaddr => $ip);
			$ipAddrTable->{$ip}->iptype(4);
			$ipAddrTable->{$ip}->disco($data->{system}->disco);
			
			$snmp_oid = $self->get_oid_by_name('ipAdEntIfIndex') . '.' . $ip;
			$res2 = $self->snmp_get($snmp_oid);
			
			# Fetch interface indexes
			if ( defined($res2) ) 
			{ 
				$ipAddrTable->{$ip}->ipadentifindex($res2);
			}
			
			# Fetch ip netmask
			$snmp_oid = $self->get_oid_by_name('ipAdEntNetMask') . '.' . $ip;
			$res2 = $self->snmp_get($snmp_oid);
			if ( defined($res2) ) 
			{ 
				$ipAddrTable->{$ip}->ipadentnetmask($res2);
			}
		}
	}
	
	#
	# Next discover ip v6 addresses
	#
	$snmp_oid = $self->get_oid_by_name('ipAddressIfIndex.ipv6');
	$res1 = $self->snmp_table($snmp_oid);
	if ( defined($res1) )
	{
		foreach $oid (keys %$res1)
		{
			my $ip = $res1->{$oid};
			my @ip = ();
			$ip =~ s/^$snmp_oid\.//;
			my $newoid = $self->get_oid_by_name('ipAddressPrefix.ipv6') . $ip;
			foreach my $byte ( split(/\./,$ip) )
			{
				push(@ip, sprintf("%x",$byte) );
			}
			$ip = join(':', @ip);
			$ipAddrTable->{$ip} = ActiveCMDB::Object::ipAdEntry->new(device_id => $self->device_id, ipadentaddr => $ip);
			$ipAddrTable->{$ip}->ipadentifindex($res1->{$oid});
			$ipAddrTable->{$ip}->iptype(6);
			$ipAddrTable->{$ip}->disco($data->{system}->disco);
			
			$res2 = $self->snmp_get($newoid);
			if ( defined($res2) ) {
				$ipAddrTable->{$ip}->ipadentprefix($res2); 
			}
		}
	}
	
	return $ipAddrTable;
}

=item save_ipmib

Save discovered ip data to the database
Parameters:
1. $self		=> Instance of (sub)class Class::Device
2. $data		=> Data previously discovered

$data->{192.168.1.1}->{ipadenteddr} = '192.168.1.1'
                    ->{ipadentifindex} = 1
                    ->{ipadentnetmask} = '255.255.255.0'
                    ->{type} = 4
                    
=cut

sub save_ipmib
{
	my($self, $data) = @_;
	my($rs, $transaction, $result, $disco);
	
	$disco = undef;
	$transaction = sub {
		Logger->debug("Saving IP data");
		foreach my $ip (keys %$data)
		{
			Logger->debug("Saving data for $ip");
			if ( ! defined($disco) ) {
				$disco = $data->{$ip}->disco;
			}
			$data->{$ip}->save();
		}
		
		
		# Next delete adresses that weren't detected
		$rs = $self->attr->schema->resultset("IpDeviceNet")->search(
			{
				device_id	=> $self->device_id,
				disco		=> { '!=' => $disco }
			}
		);
		while (my $row = $rs->next )
		{
			$row->delete;
		}
	};
	
	try {
		$result = $self->attr->schema->txn_do($transaction);
	} catch {
		Logger->error("Transaction failed :" . $_);
	};
}