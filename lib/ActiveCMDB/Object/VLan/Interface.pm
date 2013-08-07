package ActiveCMDB::Object::VLan::Interface;

=begin nd

    Script: ActiveCMDB::Object::VLan::Interface.pm
    ___________________________________________________________________________

    Version 1.0

    Copyright (C) 2011-2015 Theo Bot

    http://www.activecmdb.org


    Topic: Purpose

    ActiveCMDB::Object::vLan class definition

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

use Moose;
use Try::Tiny;
use Logger;
use ActiveCMDB::Common::Constants;
use Data::Dumper;

has 'device_id'		=> (is => 'ro', isa => 'Int');
has 'ifindex'		=> (is => 'ro', isa => 'Int');
has 'vlan_id'		=> (is => 'rw', isa => 'Int');
has 'disco'			=> (is => 'rw', isa => 'Int');
has 'schema'		=> (is => 'rw', isa => 'Object', default => sub { ActiveCMDB::Schema->connect(ActiveCMDB::Model::CMDBv1->config()->{connect_info}) } );

sub get_data
{
	my($self) = @_;
	my($rs);
	
	try {
		$rs = $self->schema->resultset("IpDeviceIntVlan")->find(
				{
					device_id	=> $self->device_id,
					ifindex		=> $self->ifindex,
				}
		);
		
		if ( defined($rs) ) {
			$self->vlan_id($rs->vlan_id);
			$self->disco($rs->disco);
		}
		
	} catch {
		Logger->warn("Failed to get vlan record: " . $_);
	};
}

sub save 
{
	my($self) = @_;
	
	my($rs, $data, $result);
	$data = undef;
	$result = false;
	
	foreach my $key ( __PACKAGE__->meta->get_all_attributes )
	{
		my $attr = $key->name;
		next if ($attr =~ /schema/ );
		$data->{$attr} = $self->$attr;
	}
	
	#
	# Saving vlan data
	#
	Logger->debug("Saving vlan interface data");
	
	try {
		$rs = $self->schema->resultset("IpDeviceIntVlan")->update_or_create( $data );
		if ( defined($rs) ) {
			if ( !$rs->in_storage ) {
				$rs->insert;
			}
			$result = true;
		}
	} catch {
		Logger->warn("Failed to save vLan entry:" . $_);
	};
	
	return $result;
}

1;