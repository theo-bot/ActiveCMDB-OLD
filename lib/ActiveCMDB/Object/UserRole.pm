package ActiveCMDB::Object::UserRole;

=head1 ActiveCMDB::Object::User.pm
    ___________________________________________________________________________

=head1 Version 1.0

=head1 Copyright
    Copyright (C) 2011-2015 Theo Bot

    http://www.activecmdb.org


=head1 Description

    ActiveCMDB::Object::UserRole class definition

=head1 License

    This program is free software; you can redistribute it and/or
    modify it under the terms of the GNU General Public License
    as published by the Free Software Foundation; either version 2
    of the License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

=cut

#
# Include required modules 
#
use Moose;
use Moose::Util::TypeConstraints;
use Try::Tiny;
use Data::Dumper;
use DateTime;
use Logger;
use ActiveCMDB::Common::Constants;

has 'id'			=> (is => 'rw', isa => 'Int');
has 'role'		=> (is => 'rw', isa => 'Str');
with 'ActiveCMDB::Object::Methods';
my %map = (
	id				=> 'id',
	role		=> 'role',

);

# Schema
has 'schema'		=> (
	is => 'rw', 
	isa => 'Object', 
	default => sub { ActiveCMDB::Model::CMDBv1->instance() } 
);

sub get_data
{
	my($self) = @_;
	
	if ( defined($self->id) )
	{
		my $row = $self->schema->resultset("Role")->find({ id => $self->id });
		if ( defined($row) ) {
			$self->role($row->role);
		}
	}	
}

sub save
{
	my($self) = @_;
	
	if ( defined($self->role) ) 
	{	
		my $data = $self->to_hashref();
		try {
			my $row = $self->schema->resultset("Role")->update_or_create($data);
			if ( !defined($self->id) && defined($row->id) ) {
				$self->id($row->id);
			}
		} catch {
			Logger->warn("Failed to save role " . $self->role);
			Logger->debug($_);
		};
	}
}

sub delete
{
	my($self) = @_;
	my $res = '';
	if ( defined($self->id) )
	{
		try {
			my $row = $self->schema->resultset("Role")->find(id => $self->id);
			if ( defined($row) && $row->role ne 'admin') {
				$row->delete();
				$res = 'Role deleted';
			}
		} catch {
			Logger->warn("Failed to delete role " . $self->id);
			Logger->debug($_);
			$res = 'Failed to delete role';
		};
	}
	
	return $res;
}

sub exist
{
	my($self) = @_;
	
	my $count = $self->schema->resultset('Role')->search({ role => $self->role})->count;
	Logger->debug("Role count $count");
	return $count;
}

__PACKAGE__->meta->make_immutable;

1;