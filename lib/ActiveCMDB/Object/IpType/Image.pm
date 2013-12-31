package ActiveCMDB::Object::IpType::Image;

=begin nd

    Script: ActiveCMDB::Object::IpType::Image.pm
    ___________________________________________________________________________

    Version 1.0

    Copyright (C) 2011-2015 Theo Bot

    http://www.activecmdb.org


    Topic: Purpose

    Object class definition for IP Device Type Images

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

has 'type_id'		=> (is => 'ro', isa => 'Int');
has 'mime_type'		=> (is => 'rw', isa => 'Str');
has 'image'			=> (is => 'rw', isa => 'Str');

# Schema
has 'schema'		=> (
	is		=> 'rw', 
	isa		=> 'Object', 
	default => sub { ActiveCMDB::Model::CMDBv1->instance() } 
);

my $table = 'IpDeviceTypeImage';

sub get_data
{
	my($self) = @_;
	Logger->info("Fetching image object data");
	try {
		if ( defined($self->type_id) && $self->type_id > 0 )
		{
			my $row = $self->schema->resultset($table)->find({ type_id => $self->type_id });
			if ( defined($row) ) {
				Logger->debug("Setting mimetype to " . $row->mime_type);
				$self->mime_type($row->mime_type);
				$self->image($row->image);
				$row = undef;
			} else {
				Logger->warn("No image data in store.");
			}
		} else {
			Logger->warn("Type id not set " . $self->type_id );
			return 0;
		}
		return 1;
	} catch {
		Logger->warn("No image found for type_id " . $self->type_id);
		Logger->debug($_);
	};
}

sub save
{
	my($self) = @_;
	try {
		if ( defined($self->type_id) && defined($self->mime_type) && defined($self->image) )
		{
			my $data = undef;
			foreach my $attr (qw/type_id mime_type image/)
			{
				$data->{$attr} = $self->$attr();
			}
			$self->schema->resultset($table)->update_or_create($data);
			return 1;
		} else {
			Logger->warn("Incomplete data");
		}
	} catch {
		Logger->warn("Failed to save image data.");
		Logger->debug($_);
	};
}

1;