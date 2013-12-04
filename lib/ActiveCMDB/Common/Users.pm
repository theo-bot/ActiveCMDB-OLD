package ActiveCMDB::Common::Users;

=head1 MODULE - ActiveCMDB::Common::Users
    ___________________________________________________________________________

=head1 VERSION

    Version 1.0

=head1 COPYRIGHT

    Copyright (C) 2011-2015 Theo Bot

    http://www.activecmdb.org


=head1 DESCRIPTION

    Common user functions

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
use ActiveCMDB::Object::User;
use Try::Tiny;
use strict;
use Data::Dumper;

our $VERSION = '1.0';
our @ISA = ('Exporter');

our @EXPORT = qw(
	cmdb_list_users
);

sub cmdb_list_users
{
	my $schema = ActiveCMDB::Model::CMDBv1->instance();
	my $rs = $schema->resultset("User")->search({}, { columns => qw/id/} );
	my $user;
	my $roles;
	if ( defined($rs) )
	{
		format listUsers_TOP = 
Username     Firstname     Lastname        Active E-Mail             Roles
---------------------------------------------------------------------------------------------------------
.

		format listUsers =
@<<<<<<<<<<< @<<<<<<<<<<<<< @<<<<<<<<<<<<< @<<<<< @<<<<<<<<<<<<<<<<< @<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
$user->username,$user->first_name,$user->last_name,$user->active,$user->email_address,$roles
.
		$~ = 'listUsers';
		$^ = 'listUsers_TOP';
		while(my $row = $rs->next )
		{
			$user = ActiveCMDB::Object::User->new(id => $row->id);
			$user->get_data();
			$roles = join(',', $user->roles());
			write;
		}
	}
}


1;