package ActiveCMDB::Object::Vendor;

=begin nd

    Script: ActiveCMDB::Object::Vendor.pm
    ___________________________________________________________________________

    Version 1.0

    Copyright (C) 2012-2013 Theo Bot

    http://www.activecmdb.org


    Topic: Purpose

    Vendor object class definition

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

has 'id'			=> (is => 'ro',	isa => 'Str');
has 'name'			=> (is => 'rw', isa => 'Str');
has 'phone'			=> (is => 'rw', isa => 'Str');
has 'support_phone'	=> (is => 'rw', isa => 'Str');
has 'support_email'	=> (is => 'rw', isa => 'Str');
has 'support_www'	=> (is => 'rw', isa => 'Str');
has 'enterprises'	=> (is => 'rw', isa => 'Any');
has 'details'		=> (is => 'rw', isa => 'Any');

# Schema
has 'schema'		=> (is => 'rw', isa => 'Object', default => sub { ActiveCMDB::Schema->connect(ActiveCMDB::Model::CMDBv1->config()->{connect_info}) } );

sub find
{
	my ($self) = @_;
	my($row,$attr);
	
	$row = $self->schema->resultset("Vendor")->find({vendor_id => $self->id});
	if ( defined($row) )
	{
		foreach $attr (qw/name phone support_phone support_email support_www enterprises details/)
		{
			my $m = 'vendor_' . $attr;
			$self->$attr($row->$m());
		}
	}
	
}

1;