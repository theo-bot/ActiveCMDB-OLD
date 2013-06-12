package Class::Device::BridgeMib;

=begin nd

    Script: CMDB::Device::BridgeMib.pm
    ___________________________________________________________________________

    Version 1.0

    Copyright (C) 2013-2015 Theo Bot

    http://www.activecmdb.org


    Topic: Purpose

    Class::Device::BridgeMib class definition

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
use Data::Dumper;
use Try::Tiny;
use Logger;
use ActiveCMDB::Common::Constants;
use ActiveCMDB::Object::BridgePort;

=item discover_bridgemib

Discover bridgemib hardware adresses

=cut

sub discover_bridgemib
{
	my($self,$data) = @_;
	my($vlan,$oid, $oid1, $oid2, $oid3, $res, $cs);
	my %cs = ();
	my @vlans = $self->_vlans();
	$cs = $self->attr->snmp_ro;
	my %port2ifindex = ();
	my $bridgemib	 = undef;
	
	$cs{$cs} = "";
	
	foreach $vlan (@vlans) { $cs{ $cs . '@'. $vlan } = $vlan; }
	
	foreach $cs (keys %cs)
	{
		$vlan = $cs{$cs};
		
		if ( $self->snmp_connect($cs) )
		{
			# First get port to ifindex remapping
			$oid1 = $self->get_oid_by_name('dot1dBasePortIfIndex');
			$res = $self->snmp_table($oid1);
			
			if ( defined($res) )
			{
				foreach $oid (keys %$res)
				{
					$oid =~ /^.*\.(\d+)$/;
					$port2ifindex{$1} = $res->{$oid};
				}
			} else {

				Logger->warn("Failed to get dot1dBasePortIfIndex for $vlan");
			}
			# Doneifindex remapping
			
			#
			# Processing dot1dTpFdbAddress
			#
			$oid2 = $self->get_oid_by_name('dot1dTpFdbAddress');
			$res = $self->snmp_table($oid2);
			
			if ( defined($res) )
			{
				Logger->debug(Dumper($res));
				foreach $oid (keys %$res)
				{
					
					my $mac = $res->{$oid};
					my $key = _oidkey($oid2, $oid);
					Logger->debug("$key - $oid => " . $res->{$oid});
					$bridgemib->{$key}->{mac} = uc($mac);
					$bridgemib->{$key}->{mac} =~ s/^0X//;
				}
				
				
			} else {

				Logger->warn("Failed to get dot1dTpFdbAddress for $vlan");
			}
			# Done dot1dTpFdbAddress
			
			#
			# Processing dot1dTpFdbPort
			#
			$oid3 = $self->get_oid_by_name('dot1dTpFdbPort');
			$res = $self->snmp_table($oid3);
			if ( defined($res) )
			{
				
				foreach $oid (keys %$res)
				{
					my $key = _oidkey($oid3, $oid);
					Logger->debug("$key - $oid => " . $res->{$oid});
					$bridgemib->{$key}->{ifIndex} = $port2ifindex{$res->{$oid}};
				}
				
			} else {
				Logger->warn("Failed to get dot1dTpFdbPort for vlan $vlan");
			}
			# Done dot1dTpFdbPort
		} else {
			Logger->warn("Failed to connect via vlan $vlan using $cs");
		}
	}
	
	$self->snmp_connect($self->attr->snmp_ro);
	
	
	
	return $bridgemib;
}

sub save_bridgemib
{
	my($self, $data) = @_;
	my($key, $bridgeport, $transaction);
	
	$transaction = sub {
		foreach $key (keys %$data)
		{
			$bridgeport = ActiveCMDB::Object::BridgePort->new(
				device_id	=> $self->attr->device_id,
				ifindex		=> $data->{$key}->{ifIndex},
				mac			=> $data->{$key}->{mac},
				disco		=> $self->attr->disco 
			);
		
			$bridgeport->save();
		}
	};
	
	try {
		$self->attr->schema->txn_do($transaction);
	} catch {
		Logger->warn("Failed to save bridgemib data: " . $_);
	}
}

sub _vlans
{
	my($self) = @_;
	my(@rs, @vlans);
	
	
	@vlans = (0);
	
	@rs = $self->attr->schema->resultset("IpDeviceVlan")->search(
				{
					device_id => $self->attr->device_id
				},
				{
					columns 	=> [ 'vlan_id' ],
					order_by	=> 'vlan_id'
				}
	);
	
	if ( scalar @rs > 0 ) {
		foreach my $row (@rs) {
			push(@vlans, $row->vlan_id);
		}
	}
	
	return @vlans;
}

sub _oidkey {
	my($baseoid, $oid) = @_;
	my @b = split(/\./, $baseoid);
	my @o = split(/\./, $oid);
	splice(@o, 0, $#b + 1);
	return join('.', @o);
}

1;