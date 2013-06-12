=begin nd

    Script: Class::Device::Arp.pm
    ___________________________________________________________________________

    Version 1.0

    Copyright (C) 2011-2015 Theo Bot

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
package Class::Device::Arp;

use Moose::Role;
use Try::Tiny;
use ActiveCMDB::Common::Constants;
use ActiveCMDB::Object::atEntry;
use Logger;
use Data::Dumper;

my(%atEntry);

%atEntry = (
				'atIfIndex'		=> 'atifindex',
				'atPhysAddress'	=> 'atphysaddress',
				'atNetAddress'	=> 'atnetaddress'
			);
			
sub discover_arp
{
	my($self, $data) = @_;
	
	my($oid, $res, $snmp_oid, $arp_data, $object);
	
	$arp_data = undef;
	
	foreach $object (keys %atEntry)
	{
		$snmp_oid = $self->get_oid_by_name($object);
		my $method = $atEntry{$object};
		$res = $self->snmp_table($snmp_oid);
		if ( defined($res) )
		{
			foreach $oid (keys %$res)
			{
				my($key, $value);
				
				$key = _oidkey($snmp_oid, $oid);
				if ( ! defined($arp_data->{$key}) )
				{
					$arp_data->{$key} = ActiveCMDB::Object::atEntry->new(device_id => $self->attr->device_id);
				}
				$value = uc($res->{$oid});
				$value =~ s/^0X//;
				$arp_data->{$key}->$method($value);
				
				$arp_data->{$key}->disco($data->{system}->disco);
				
			}
		}
	}
	
	return $arp_data;
}

sub save_arp
{
	my($self, $data) = @_;
	my($transaction, $rs, $atEntry, $txnres, $result);
	
	$transaction = sub {
		
		foreach my $key (keys %$data)
		{
			$data->{$key}->save();
		}
	};
	
	try
	{
		$result = $self->attr->schema->txn_do($transaction);
	} catch {
		Logger->error("Transaction failed" . $_);
	};
}

sub _oidkey {
	my($baseoid, $oid) = @_;
	my @b = split(/\./, $baseoid);
	my @o = split(/\./, $oid);
	splice(@o, 0, $#b + 1);
	return join('.', @o);
}

1;