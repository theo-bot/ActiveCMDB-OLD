package Class::Device::Interface;

=begin nd

    Script: CMDB::Device::Interface.pm
    ___________________________________________________________________________

    Version 1.0

    Copyright (C) 2012-2013 Theo Bot

    http://www.activecmdb.org


    Topic: Purpose

    Class::Device::System class definition

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
use Logger;
use ActiveCMDB::Common::Constants;
use ActiveCMDB::Object::ifEntry;
use Data::Dumper;
use Try::Tiny;
my(%ifentry, %ifmib);

%ifentry	= (	'ifIndex'		=> 'ifindex',
			'ifDescr'		=> 'ifdescr',
			'ifType'		=> 'iftype',
			'ifSpeed'		=> 'ifspeed',
			'ifPhysAddress'	=> 'ifphysaddress',
			'ifAdminStatus'	=> 'ifadminstatus',
			'ifOperStatus'	=> 'ifoperstatus',
			'ifLastChange'	=> 'iflastchange'
			);
			
%ifmib		= (
			'ifName'		=> 'ifname',
			'ifAlias'		=> 'ifalias',
			'ifHighSpeed'	=> 'ifhighspeed'
			);

sub discover_interfaces {
	my($self, $data) = @_;
	
	my($oid, $res, $interfaces);
	
	Logger->debug("Starting interface discovery for " . $self->attr->hostname);
	
	$oid = $self->get_oid_by_name('ifNumber');
	
	$res = $self->snmp_get($oid);
	
	if ( $res > SNMP_LARGE_IFTABLE )
	{
		$interfaces = $self->_discover_xl_iftable($data);
	} else {
		$interfaces = $self->_discover_iftable($data);
	}
	
	return $interfaces;
}

=item save_interfaces

=cut

sub save_interfaces
{
	my($self, $data) = @_;
	my($rs, $row, $ifIndex, $transaction, $result);
	
	$transaction = sub {
		foreach $ifIndex (keys %{$data})
		{
			# Save the object
			$data->{$ifIndex}->save();
		}
	
		#
		# Now delete interfaces that weren't detected
		#
		$rs = $self->attr->schema->resultset("IpDeviceInt")->search(
			{
				device_id	=> $self->device_id,
				disco		=> { '!=', $self->attr->disco },
			}
		);
		while ( my $int = $rs->next )
		{
			$int->delete;
		}
		return true;
	};
	
	try
	{
		$result = $self->attr->schema->txn_do($transaction);
	} catch {
		Logger->error("Transaction failed: " . $_);
	};
}

=item discover_ifmib

Discover items from the IF-MIB like:
- ifName
- ifAlias
- ifHighSpeed

=cut

sub discover_ifmib
{
	my($self, $data) = @_;
	my($res, $oid, $ifXTable, $res_oid, $method);
	
	$ifXTable = undef;
	foreach my $table (keys %ifmib)
	{
		if ( $ifmib{$table} )
		{
			$oid = $self->get_oid_by_name($table);
			$res = $self->snmp_table($oid);
			if ( defined($res ) )
			{
				foreach $res_oid ( keys %$res )
				{
					my $value = $res->{$res_oid};
					$res_oid =~ /^.*\.(\d+)$/;
					my $index = $1;
					if ( ! defined($ifXTable->{$index}) ) {
						$ifXTable->{$index} = ActiveCMDB::Object::ifEntry->new(device_id => $self->device_id, ifindex => $index);
						$ifXTable->{$index}->get_data();
					}
					$method = lc($table);
					$ifXTable->{$index}->$method($value);
				}
			}
		}
	}
	
	return $ifXTable
}

=item save_ifmib

Saving the ifmib data
Parameters:
1. $self - Class::Device or subclass device type
2. $data - ifmib data discovered by discover ifmib

=cut

sub save_ifmib
{
	my($self, $data) = @_;
	my($rs, $row, $ifIndex, $transaction, $result);
	Logger->info("Saving ifmib data");
	$transaction = sub {
		foreach $ifIndex (keys %{$data})
		{
			$data->{$ifIndex}->save();
		}
	};
	
	try
	{
		$result = $self->attr->schema->txn_do($transaction);
	} catch {
		Logger->error("Transaction failed: " . $_);
	};
	
	Logger->info("Done saving ifmib");
}

sub _discover_iftable {
	my($self, $data) = @_;
	my($ifdata, $oid, $res, $res_oid, $method);
	
	$ifdata = undef;
	foreach my $table (keys %ifentry )
	{
		if ( $ifentry{$table} ) {
			$oid = $self->get_oid_by_name($table);
			$res = $self->snmp_table($oid);
			if ( defined($res) )
			{
				
				foreach $res_oid ( keys %{$res} )
				{
					my $value = $res->{$res_oid};
					$res_oid  =~ /^.*\.(\d+)$/;
					my $index = $1;
					if ( ! defined($ifdata->{$index}) ) {
						Logger->debug("Creating new ifEntry object");
						$ifdata->{$index} = ActiveCMDB::Object::ifEntry->new(device_id => $self->device_id, ifindex => $index);
						Logger->debug("Obtaining ifEntry");
						$ifdata->{$index}->get_data();
						
						# Storing new discovery timestamp
						$ifdata->{$index}->disco($data->{system}->disco);
					}
					if ( $table eq 'ifPhysAddress')
					{
						$value = uc($value);
						$value =~ s/^0X//;
					}
					$method = lc($table);
					if ( $method !~ /device_id|ifindex/ ) {
						Logger->debug("Calling $method with value $value");
						$ifdata->{$index}->$method($value);
					}
				}
			}
		}
	}
	
	return $ifdata;
}


1;