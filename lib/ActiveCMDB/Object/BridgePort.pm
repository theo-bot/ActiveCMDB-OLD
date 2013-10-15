package ActiveCMDB::Object::BridgePort;

=begin nd

    Script: ActiveCMDB::Object::BridgePort.pm
    ___________________________________________________________________________

    Version 1.0

    Copyright (C) 2011-2015 Theo Bot

    http://www.activecmdb.org


    Topic: Purpose

    ActiveCMDB::Object::BridgePort class definition

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
use Data::Dumper;

has 'device_id'		=> (is => 'ro', isa => 'Int');
has 'ifindex'		=> (is => 'rw', isa => 'Int');
has 'mac'			=> (is => 'rw', isa => 'Str');
has 'disco'			=> (is => 'rw', isa => 'Int');
# Schema
has 'schema'		=> (
	is		=> 'rw', 
	isa		=> 'Object', 
	default => sub { ActiveCMDB::Model::CMDBv1->instance() } 
);
sub get_data
{
	my($self) = @_;
	
	my($rs);
	
	try {
		$rs = $self->schema->resultset("IpDeviceMac")->find(
				{
					device_id	=> $self->device_id,
					ifindex		=> $self->ifindex,
					mac			=> $self->mac
				}
			);
	} catch {
		Logger->debug("Error fetching bridge entry: " . $_);
	};
	
	if ( defined($rs) )
	{
		foreach my $key ( __PACKAGE__->meta->get_all_attributes )
		{
			my $attr = $key->name;
			next if ( $attr =~ /schema|device_id/ );
			$self->$attr($rs->$attr);
		}
	}
	
}

sub save
{
	my($self) = @_;
	
	my($rs,$data);
	$data = undef;
	foreach my $key ( __PACKAGE__->meta->get_all_attributes )
	{
		my $attr = $key->name;
		next if ($attr =~ /schema/ );
		$data->{$attr} = $self->$attr;
	}
	
	try {
		$rs = $self->schema->resultset("IpDeviceMac")->update_or_create($data);
		if ( ! $rs->in_storage ) {
			$rs->insert;
		}
	} catch {
		Logger->error("Failed to save BidgePort :" . $_);
	};
}

1;