package Class::Cisco::vmVlan;

=begin nd

    Script: Class::Cisco::vmVlan.pm
    ___________________________________________________________________________

    Version 1.0

    Copyright (C) 2011-2015 Theo Bot

    http://www.activecmdb.org


    Topic: Purpose

    Class::Cisco::vmVlan class definition

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

use Moose::Role;
use Try::Tiny;
use Logger;
use ActiveCMDB::Common::Constants;
use ActiveCMDB::Common::Conversion;
use ActiveCMDB::Object::VLan;
use ActiveCMDB::Object::VLan::Interface;
use ActiveCMDB::Object::ifEntry;
use Data::Dumper;

my %vars = (
				'vlanTrunkPortDynamicStatus'	=> 1,
				'vmVlan'						=> 1,
			);


=item discover_vmvlan

Discover vlan's on cisco switches and uplink/trunk ports

=cut

sub discover_vmVlan
{
	my($self, $data) = @_;
	my($oid, $res,$object,$ifIndex,$value, $snmp_oid, $result);
	
	
	
	#
	# Reset result 
	#
	$result = undef;
	
	foreach $object (keys %vars)
	{
		$snmp_oid = $self->get_oid_by_name($object);
		Logger->info("Retrieving table $object :: $snmp_oid");
		$res = $self->snmp_table($snmp_oid);
		if ( defined($res) )
		{
			foreach $oid ( keys %$res )
			{
				$oid =~ /^.*\.(\d+)$/;
				$ifIndex = $1;
				$value = $res->{$oid};
				# 'Translate' the 2 value to 0, which means not trunking
				if ( $object eq 'vlanTrunkPortDynamicStatus' && $value == 2 ) { $value = 0; }
				
				$result->{int}->{$ifIndex}->{$object} = $value;
				$result->{int}->{$ifIndex}->{disco} = $data->{system}->disco;
				
			}
		} else {
			Logger->warn("Failed to retrieve $object :".$self->snmp_error());
		}
	}
	
	$snmp_oid = $self->get_oid_by_name('vtpVlanState');
	$res = $self->snmp_table($snmp_oid);
	if ( defined($res) )
	{
		#
		# Fetch mib defined values
		#
		my %vtpState = cmdb_oid_set('vtpVlanState');
		my %vtpType  = cmdb_oid_set('vtpVlanType');
		
		foreach $oid ( keys %{$res} )
		{
			$oid =~ /^.*\.(\d+)$/;
			my $vlan = $1;
			$result->{vlan}->{$vlan}->{state} = $vtpState{$res->{$oid}};
			$result->{vlan}->{$vlan}->{disco} = $data->{system}->disco;
		}
		
		$snmp_oid = $self->get_oid_by_name('vtpVlanName');
		$res = $self->snmp_table($snmp_oid);
		if ( defined($res) ) 
		{
			foreach $oid ( keys %{$res} )
			{
				$oid =~ /^.*\.(\d+)$/;
				my $vlan = $1;
				$result->{vlan}->{$vlan}->{name} = $res->{$oid};
			}
		}
		
		$snmp_oid = $self->get_oid_by_name('vtpVlanType');
		$res = $self->snmp_table($snmp_oid);
		if ( defined($res) ) 
		{
			foreach $oid ( keys %{$res} )
			{
				$oid =~ /^.*\.(\d+)$/;
				my $vlan = $1;
				$result->{vlan}->{$vlan}->{type} = $vtpType{$res->{$oid}};
			}
		}
		
		Logger->debug(Dumper($result));
	}
	
	
	#
	# Return the data
	#
	return $result;
} 

sub save_vmVlan
{
	my($self, $data) = @_;
	my($ifindex, $interface, $result, $vlan, $vlan_id, $transaction);
	
	$transaction = sub {
		#
		# Update vlan data
		#
		foreach $vlan_id (keys %{$data->{vlan}})
		{
			$vlan = ActiveCMDB::Object::VLan->new(device_id => $self->attr->device_id, vlan_id => $vlan_id);
			$vlan->get_data();
			$vlan->name( $data->{vlan}->{$vlan_id}->{name} );
			$vlan->status( $data->{vlan}->{$vlan_id}->{state} );
			$vlan->type( $data->{vlan}->{$vlan_id}->{type} );
			$vlan->disco( $data->{vlan}->{$vlan_id}->{disco} );
			$vlan->save();
		}
	};
	
	try {
		$result = $self->attr->schema->txn_do( $transaction );
	} catch {
		Logger->error("Failed to save vlan data: " . $_);
	};
	
	$transaction = sub {
		foreach $ifindex (keys %{$data->{int}})
		{
			#
			# Update interfaces
			#
			$interface = ActiveCMDB::Object::ifEntry->new(device_id => $self->attr->device_id, ifindex => $ifindex);
			$interface->get_data();
			$interface->istrunk($data->{int}->{$ifindex}->{vlanTrunkPortDynamicStatus});
			$interface->save();
		
			#
			# Update vlandata
			#
			$vlan = ActiveCMDB::Object::VLan::Interface->new(device_id => $self->attr->device_id, ifindex => $ifindex);
			$vlan->vlan_id($data->{int}->{$ifindex}->{vmVlan});
			$vlan->disco($data->{int}->{$ifindex}->{disco});
			$vlan->save();
		}
	};
	
	Logger->debug("Saving vmVlan data");
	try {
		$result = $self->attr->schema->txn_do( $transaction );
	} catch {
		Logger->error("Failed to save vlan data: " . $_);
	};
	
	
	
}

1;