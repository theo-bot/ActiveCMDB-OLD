package ActiveCMDB::Object::User;


=head1 ActiveCMDB::Object::User.pm
    ___________________________________________________________________________

=head1 Version 1.0

=head1 Copyright
    Copyright (C) 2011-2015 Theo Bot

    http://www.activecmdb.org


=head1 Description

    ActiveCMDB::Object::User class definition

=head1 License

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
use Data::Dumper;
use DateTime;
use Logger;
use ActiveCMDB::Common::Constants;

has 'id'		=> (is => 'rw', isa => 'Int');
has 'username'	=> (is => 'ro', isa => 'Str');

# Schema
has 'schema'		=> (
	is => 'rw', 
	isa => 'Object', 
	default => sub { ActiveCMDB::Model::CMDBv1->instance() } 
);


sub get_data
{
	my($self) = @_;
	
	if ( defined($self->username) ) {
		my $row = $self->schema->resultset("User")->find({ username => $self->username });
		if ( defined($row) ) {
			$self->id($row->id);
		} else {
			print "Row not found\n";
		}
	} else {
		print "Username not set\n";
	}
}

sub has_role
{
	my($self, $role) = @_;
	
	if ( defined($role) && defined($self->username) )
	{
		my $rs = $self->schema->resultset("User")->search(
				{
					username	=> $self->username,
					'role.role'	=> $role
				},
				{
					join		=> { map_user_role =>  'role' },
					+select		=> ['username','role.role'],
					+as			=> ['username','role_name']
				}	
		);
		
		if ( defined($rs) && $rs->count() > 0 ) {
			return true;
		}
	}
}

1;