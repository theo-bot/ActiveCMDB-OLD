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
use ActiveCMDB::Object::IpType::Image;
use namespace::clean;
use Try::Tiny;
use Logger;

has 'type_id'		=> (is => 'rw', isa => 'Int');
has 'sysobjectid'	=> (is => 'ro',	isa => 'Str');
has 'descr'			=> (is => 'rw', isa => 'Str');
has 'vendor_id'		=> (is => 'rw', isa => 'Int');
has 'disco_scheme'	=> (is => 'rw', isa => 'Int');
has 'active'		=> (is => 'rw', isa => 'Int', default => 0 );
has 'networktype'	=> (is => 'rw', isa => 'Int');
has 'class'			=> (is => 'rw', isa => 'Int', default => 1);
has 'image'			=> (is => 'rw', isa => 'Maybe[Str]');
has 'objectclass'	=> (is => 'rw', isa => 'Maybe[Str]', default => 'Device');
has 'image'			=> (is => 'rw', isa => 'Object');

with 'ActiveCMDB::Object::Methods';

# Schema
has 'schema'		=> (
	is		=> 'rw', 
	isa		=> 'Object', 
	default => sub { ActiveCMDB::Model::CMDBv1->instance() } 
);

my %map = (
	'type_id'		=> 'type_id',
	'sysobjectid'	=> 'sysobjectid',
	'descr'			=> 'descr',
	'vendor_id'		=> 'vendor_id',
	'disco_scheme'	=> 'disco_scheme',
	'active'		=> 'active',
	'networktype'	=> 'networktype',
	'class'			=> 'class',
	'objectclass'	=> 'objectclass'
);

my $table = 'IpDeviceType';

sub get_data
{
	my ($self) = @_;
	my($row);
	
	$row = $self->schema->resultset($table)->find({sysobjectid => $self->sysobjectid});
	if ( defined($row) )
	{
		foreach my $attr (keys %map)
		{ 
			if ( $self->meta->get_attribute( $attr )->get_write_method ) {
				$self->$attr($row->$attr());
			}
		}
		$self->image( ActiveCMDB::Object::IpType::Image->new(type_id => $self->type_id ) );
	} else {
		Logger->warn("Object type not found " . $self->sysobjectid);
	}
	
}

sub find {
	my($self) = @_;
	
	return $self->get_data();
}

sub save
{
	my($self) = @_;
	try {
		if ( $self->sysobjectid =~ /^\./ ) {
			my $oid = $self->sysobjectid;
			$oid =~ s/^\.//;
			$self->sysobjectid($oid);
		}
	
		my $data = $self->to_hashref(\%map);
	
		my $row = $self->schema->resultset($table)->update_or_create($data);
	
		if ( !defined($self->type_id) ) {
			$self->type_id($row->type_id);
		}
		return 1;
	} catch {
		return 0;
	}
}

sub delete 
{
	my($self) = @_;
	
	if (!defined($self->type_id) && defined($self->sysobjectid) ) {
		$self->get_data();
	}
	
	if ( defined($self->type_id) ) {
		my $row = $self->schema->resultset($table)->find( type_id => $self->type_id);
		if ( defined($row) ) {
			$row->delete();
		}
	}
}

sub vendor
{
	my($self) = @_;
	
	if ( defined($self->vendor_id) && $self->vendor_id > 0 ) {
		my $vendor = ActiveCMDB::Object::Vendor->new(id => $self->vendor_id);
		$vendor->get_data();
	
		return $vendor;
	}
}

sub map
{
	my($self) = @_;
	
	return \%map;
}

1;