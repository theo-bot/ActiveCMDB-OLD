package ActiveCMDB::Common::Roles;

=head1 MODULE - ActiveCMDB::Common::Roles
    ___________________________________________________________________________

=head1 VERSION

    Version 1.0

=head1 COPYRIGHT

    Copyright (C) 2011-2015 Theo Bot

    http://www.activecmdb.org


=head1 DESCRIPTION

    Common user role functions

=head1 LICENSE

    This program is free software; you can redistribute it and/or
    modify it under the terms of the GNU General Public License
    as published by the Free Software Foundation; either version 2
    of the License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

=cut

=head1 IMPORTS
 use Exporter;
 use Logger;
 use ActiveCMDB::Model::CMDBv1;
 use Try::Tiny;
 use strict;
 use Data::Dumper;
=cut

use Exporter;
use Logger;
use ActiveCMDB::Model::CMDBv1;
use ActiveCMDB::Object::UserRole;
use Try::Tiny;
use strict;
use Data::Dumper;

our $VERSION = '1.0';
our @ISA = ('Exporter');

our @EXPORT = qw(
	getRoleByName
	cmdb_list_roles
);

sub getRoleByName
{
	my($name) = @_;
	Logger->info("Fetching role id for $name");
	my $schema = ActiveCMDB::Model::CMDBv1->instance();
	my $row = $schema->resultset("Role")->find({ role => $name });
	if ( defined($row) ) { return $row->id; }
}

sub cmdb_list_roles
{
	my $schema = ActiveCMDB::Model::CMDBv1->instance();
	my $rs = $schema->resultset("Role")->search({}, { columns => qw/id/} );
	my $role; 
	
	if ( defined($rs) )
	{
		format listRoles_TOP = 
ID     Role         
--------------------
.

		format listRoles =
@>>>>> @<<<<<<<<<<<<< 
$role->id,$role->role
.
		$~ = 'listRoles';
		$^ = 'listRoles_TOP';
		while(my $row = $rs->next )
		{
			$role = ActiveCMDB::Object::UserRole->new(id => $row->id);
			$role->get_data();
			write;
		}
	}
}

1;