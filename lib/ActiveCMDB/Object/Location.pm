package ActiveCMDB::Object::Location;

=begin nd

    Script: ActiveCMDB::Object::Location.pm
    ___________________________________________________________________________

    Version 1.0

    Copyright (C) 2012-2013 Theo Bot

    http://www.activecmdb.org


    Topic: Purpose

    ActiveCMDB::Object::Location class definition

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

#
# Include required modules 
#
use Moose;
use Moose::Util::TypeConstraints;
use Try::Tiny;
use Logger;
use ActiveCMDB::Model::CMDBv1;
use ActiveCMDB::Schema;
use ActiveCMDB::Common::Constants;


with 'ActiveCMDB::Object::Methods';
#
# Define attributes
#
has 'location_id'		=> (is => 'ro', isa => 'Int');
has 'ltype'				=> (is => 'rw', isa => 'Int', default => 0);
has 'parent_id'			=> (is => 'rw', isa => 'Int', default => 0);
has 'name'				=> (is => 'rw', isa => 'Str');
has 'lattitude'			=> (is => 'rw', isa => 'Str|Undef' );
has 'longitude'			=> (is => 'rw', isa => 'Str|Undef');
has 'classification'	=> (is => 'rw', isa => 'Str|Undef');
has 'primary_phone'		=> (is => 'rw', isa => 'Str|Undef');
has 'primary_contact'	=> (is => 'rw', isa => 'Str|Undef');
has 'backup_phone'		=> (is => 'rw', isa => 'Str|Undef');
has 'backup_contact'	=> (is => 'rw', isa => 'Str|Undef');
has 'details'			=> (is => 'rw', isa => 'Str|Undef');
has 'adres1'			=> (is => 'rw', isa => 'Str|Undef');
has 'adres2'			=> (is => 'rw', isa => 'Str|Undef');
has 'zipcode'			=> (is => 'rw', isa => 'Str|Undef');


# Schema
has 'schema'		=> (is => 'rw', isa => 'Object', default => sub { ActiveCMDB::Schema->connect(ActiveCMDB::Model::CMDBv1->config()->{connect_info}) } );

sub get_data
{
	my($self) = @_;
	my($row);
	
	if ( $self->location_id > 0 )
	{
		$row = $self->schema->resultset("Location")->find({ location_id => $self->location_id });
		if ( defined($row) )
		{
			foreach my $key ( __PACKAGE__->meta->get_all_attributes )
			{
				my $attr = $key->name;
				
				next if ( $attr =~ /schema|location_id/ );
				my $dattr = $attr;
				$dattr =~ s/^ltype$/type/;
				
				$self->$attr($row->$dattr);
			}
		}		
	}
}

sub site_parent
{
	my($self) = @_;
	my($parent, $p);
	
	$p = '';
	
	if ( $self->location_id > 0 )
	{
		$parent = $self->schema->resultset("Location")->find( { location_id => $self->parent_id } );
		
		if ( defined($parent) )
		{
			my $tsite = $parent;
			$p = $tsite->name;
			while ( $tsite->type > 0 )
			{
				my $parent_id = $tsite->parent_id;
				$tsite = $self->schema->resultset('Location')->find({ location_id => $parent_id });
				if ( defined( $tsite) )
				{
					$p = $tsite->name . '/' . $p;
				}
			}
		} 
	}
	return $p;
}

sub place
{
	my($self) = @_;
	my $place = '';
	
	if ( $self->parent_id > 0 ) {
		my $row = $self->schema->resultset("Location")->find( { location_id => $self->parent_id } );
		if ( defined($row) && $row->type == 2 )
		{
			$place = $row->name;
		} 
	}
	
	return $place;
}

sub save
{
	my($self) = @_;
	
	# Init variables
	my($data, $attr,$rs);
	my @columns = ();
	
	$data = undef;
	
	@columns = $self->schema->source("Location")->columns;
	foreach $attr (@columns)
	{
		if ( $self->can($attr) && defined($self->$attr) )
		{
			if ( $attr eq 'location_id' )
			{
				$data->{$attr} = $self->$attr || undef;	
			} else {
				$data->{$attr} = $self->$attr;
			}
		}
	}
	
	try {
		$rs = $self->schema->resultset("IpDevice")->update_or_create( $data );
		if ( ! $rs->in_storage ) {
			$rs->insert;
		}
		
		return true;
	} catch {
		return false;
	}
	
}

1;