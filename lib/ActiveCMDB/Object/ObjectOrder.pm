package ActiveCMDB::Object::ObjectOrder;

=begin nd

    Script: ActiveCMDB::Object::IpType.pm
    ___________________________________________________________________________

    Version 1.0

    Copyright (C) 2011-2015 Theo Bot

    http://www.activecmdb.org


    Topic: Purpose

    Object class definition for object manager orders

    About: License

    This program is free software; you can redistribute it and/or
    modify it under the terms of the GNU General Public License
    as published by the Free Software Foundation; either version 2
    of the License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

   
=cut

#########################################################################
# Initialize  modules
use Moose;
use Moose::Util::TypeConstraints;
use namespace::clean;
use Try::Tiny;
use DateTime;
use Logger;
use ActiveCMDB::Common::Constants;
use Data::UUID;

my $ug = new Data::UUID;

has cid			=> (is => 'rw', isa => 'Str', default => sub { $ug->create_str(); } );
has device_id	=> (is => 'rw', isa => 'Int' );
has ts			=> (is => 'rw', isa => 'Int' );
has dest		=> (is => 'rw', isa => 'Str' );

with 'ActiveCMDB::Object::Methods';

# Schema
has 'schema'		=> (
	is		=> 'rw', 
	isa		=> 'Object', 
	default => sub { ActiveCMDB::Model::CMDBv1->instance() } 
);

my %map = (
	cid			=> 'cid',
	device_id	=> 'device_id',
	ts			=> 'ts',
	dest		=> 'dest'
);

my $table = 'DeviceOrder';

sub get_data
{
	my($self) = @_;
	my $result = false;
	
	try {
		if ( defined($self->cid) ) {
			my $row = $self->schema->resultset($table)->find({ cid => $self->cid });
			if ( defined($row) ) {
				$self->populate($row, \%map);
				$result = true;
			}
		}
	} catch {
		Logger->warn("Failed to find order " . $self->cid);
		Logger->debug($_);
	};
	
	return $result;
}

sub save 
{
	my($self) = @_;
	my $result = false;
	Logger->debug("Saving device order");
	try {
		if ( defined($self->cid) ) {
			my $data = $self->to_hashref(\%map);
			if ( $self->schema->resultset($table)->update_or_create($data) )
			{
				$result = true; 
				Logger->info("Saved device order");
			} else {
				Logger->warn("Failed to save order");
			}
		} else {
			Logger->warn("Cannot save order, no cid defined.");
		}
	} catch {
		Logger->warn("Failed to save device order");
		Logger->debug($_);
	};
	
	return $result;
}

sub delete
{
	my($self) = @_;
	my $result = false;
	
	try {
		if ( defined($self->cid) ) {
			my $row = $self->schema->resultset($table)->find({ cid => $self->cid });
			if ( defined($row) ) {
				$row->delete();
				$result = true;
			}
		}
	} catch {
		Logger->warn("Failed to find and delete order " . $self->cid);
		Logger->debug($_);
	};
	
	return $result;
}

sub is_expired
{
	my($self, $maxage) = @_;
	
	if ( time() - $self->ts > $maxage ) { return true; }
}

__PACKAGE__->meta->make_immutable;

1;