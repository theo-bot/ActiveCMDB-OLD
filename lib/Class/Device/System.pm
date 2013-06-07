package Class::Device::System;

=begin nd

    Script: CMDB::Device::System.pm
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
use ActiveCMDB::Object::Device;
use Logger;
use Data::Dumper;

my %vars = ('sysDescr'		=> 'sysdescr',
			'sysName'		=> 'hostname',
			'sysObjectID'	=> 'sysobjectid',
			'sysUpTime'		=> 'sysuptime'
		);

sub discover_system
{
	my($self, $data) = @_;
	my($oid, $res, $system);
	
	Logger->debug("Discovering snmp system table for " . $self->attr->hostname);
	$oid = $self->get_oid_by_name('system');
	$res = $self->snmp_table($oid);
	
	if ( defined($res) ) {
		foreach my $key ( keys %vars )
		{
			my $attr = $vars{$key};
			$oid = $self->get_oid_by_name($key);
			
			Logger->debug("Storing $attr with oid $oid => " . $res->{$oid});
			if ( defined($res->{$oid}) ) {
				$self->attr->$attr($res->{$oid});
			}
		}
	} else {
		Logger->warn("Failed to get snmp system table :" . $self->comms->error());
	}
	$self->attr->disco(time());
	
	return $self->attr;
}

sub save_system
{
	my($self, $data) = @_;
	my($rs, $method, $ts);
	
	
	$self->attr->save();
}