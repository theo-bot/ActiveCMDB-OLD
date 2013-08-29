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


my %atEntry = (
				'atIfIndex'		=> 'atifindex',
				'atPhysAddress'	=> 'atphysaddress',
				'atNetAddress'	=> 'netaddress'
			);
			
my %ipNetToMediaEntry = (
				'ipNetToMediaIfIndex'		=> 'atifindex',
				'ipNetToMediaPhysAddress'	=> 'atphysaddress',
				'ipNetToMediaNetAddress'	=> 'atnetaddress'
			);

sub discover_arp
{
	my($self, $data) = @_;
	
	my($oid, $res, $snmp_oid, $arp_data, $object, $valid);
	
	$arp_data = undef;
	
	foreach $object (keys %atEntry)
	{
		$snmp_oid = $self->get_oid_by_name($object);
		
		$res = $self->snmp_table($snmp_oid);
		if ( defined($res) )
		{
			foreach $oid (keys %$res)
			{
				my($key, $value);
				
				$key = _oidkey($snmp_oid, $oid);
								
				$value = uc($res->{$oid});
				$value =~ s/^0X//;
				$value =~ s/\s+//g;
				$arp_data->{$key}->{$atEntry{$object}} = $value;
				
				$arp_data->{$key}->{disco} = $data->{system}->disco;
				
			}
		} else {
			Logger->warn("Failed to fetch $object");
		}
	}
	
	
	foreach $object (keys %ipNetToMediaEntry)
	{
		Logger->debug("Requesting object $object");
		$snmp_oid = $self->get_oid_by_name($object);
		
		$res = $self->snmp_table($snmp_oid);
		if ( defined($res) )
		{
			foreach $oid (keys %{$res})
			{
				my($key, $value);
				
				$key = _oidkey($snmp_oid, $oid);
								
				
				if ( $object eq 'ipNetToMediaPhysAddress'  && defined($res->{$oid}) && length($res->{$oid}) <= 8 )
				{
					my $v = '';
					foreach my $a (unpack("C*", $res->{$oid} )) { $v .= uc(sprintf("%02x", $a)); }
					$value = $v;
				} else {
					$value = uc($res->{$oid});
					$value =~ s/^0X//;
					$value =~ s/\s+//g;
				} 
				
				my $o = $ipNetToMediaEntry{$object};
				$arp_data->{$key}->{$o} = $value;
				
				$arp_data->{$key}->{disco} = $data->{system}->disco;
			}
		} else {
			Logger->warn("Failed to fetch $object");
		}
	}
	Logger->debug(Dumper($arp_data));
		
	return $arp_data;
}

sub save_arp
{
	my($self, $data) = @_;
	my($transaction, $rs, $atEntry, $txnres, $result);
	
	
	my @obect_types = values(%ipNetToMediaEntry);
	
	$transaction = sub {
		
		foreach my $key (keys %$data)
		{
			my $valid = true;
			foreach my $object (@obect_types)
			{
				if ( !defined($data->{$key}->{$object}) ) { $valid = false; }
			}
			if ( $valid ) {
				$atEntry = ActiveCMDB::Object::atEntry->new( device_id => $self->device_id );
				foreach my $object (@obect_types)
				{
					$atEntry->$object($data->{$key}->{$object});
				}
				$atEntry->disco($data->{$key}->{disco});
				$atEntry->save();
			} else {
				Logger->warn("Unable to save arp entry, incomplete data");
				Logger->debug(Dumper($data->{$key}));
			}
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