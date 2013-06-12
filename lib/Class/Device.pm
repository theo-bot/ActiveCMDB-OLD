package Class::Device;

=begin nd

    Script: Class::Device.pm
    ___________________________________________________________________________

    Version 1.0

    Copyright (C) 2011-2015 Theo Bot

    http://www.activecmdb.org


    Topic: Purpose

    Device Discovery Class definition

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

use Methods;
use Moose;
use ActiveCMDB::Schema;
use ActiveCMDB::Model::CMDBv1;
use ActiveCMDB::Object::Device;
use Logger;

has 'device_id'		=> ( is => 'ro', isa => 'Int' );
has 'attr'		=> ( is => 'rw', isa => 'Object' );

#
# Comms is communications handle
#
has 'comms'			=> ( is => 'rw');

with 'Methods';
with 'Class::Device::Icmp';
with 'Class::Device::Snmp';
with 'Class::Device::System';
with 'Class::Device::Interface';
with 'Class::Device::Arp';
with 'Class::Device::Ipmib';
with 'Class::Device::Entity';
with 'Class::Device::TcpServices';
with 'Class::Device::BridgeMib';

sub get_data
{
	my($self) = @_;
	my($rs);
	
	Logger->info("Getting object data for object type ".ref $self);
	
	$self->attr( ActiveCMDB::Object::Device->new( device_id => $self->device_id ) );
	$self->attr->find();
	
}

sub get_oid_by_name {
	my($self, $name) = @_;
	my($rs, $oid);
	
	if ( defined($name) ) {
		$rs = $self->attr->schema->resultset("Snmpmib")->search(
			{
			 	oidname => $name 
			}, 
			{
				columns => [qw/ oid /]
			})->next;
		if ( defined($rs)) {
			return $rs->oid;
		}
	}
}

sub set_disco {
	my($self, $dtime) = @_;
	
	if ( defined($dtime) )
	{
		$self->attr->discotime($dtime);
		$self->attr->save();
	}
}

__PACKAGE__->meta->make_immutable;
1;