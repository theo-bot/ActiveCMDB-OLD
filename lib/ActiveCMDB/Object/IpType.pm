package ActiveCMDB::Object::IpType;

=begin nd

    Script: ActiveCMDB::Object::IpType.pm
    ___________________________________________________________________________

    Version 1.0

    Copyright (C) 2011-2015 Theo Bot

    http://www.activecmdb.org


    Topic: Purpose

    Object class definition for IP Device Types

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
# Initialize  modules
use Moose;
use Moose::Util::TypeConstraints;
use Try::Tiny;
use Logger;

has 'sysobjectid'	=> (is => 'ro',	isa => 'Str');
has 'descr'			=> (is => 'rw', isa => 'Str');
has 'vendor_id'		=> (is => 'rw', isa => 'Int');

# Schema
has 'schema'		=> (is => 'rw', isa => 'Object', default => sub { ActiveCMDB::Schema->connect(ActiveCMDB::Model::CMDBv1->config()->{connect_info}) } );

sub find
{
	my ($self) = @_;
	my($row);
	
	$row = $self->schema->resultset("IpDeviceType")->find({sysobjectid => $self->sysobjectid});
	if ( defined($row) )
	{
		foreach my $attr (qw/descr vendor_id/)
		{ 
			$self->$attr($row->$attr());
		}
		
	}
	
}

1;