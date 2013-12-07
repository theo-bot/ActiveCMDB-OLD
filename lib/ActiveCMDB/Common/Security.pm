package ActiveCMDB::Common::Security;
=head1 MODULE - ActiveCMDB::Common::Security
    ___________________________________________________________________________

=head1 VERSION

    Version 1.0

=head1 COPYRIGHT

    Copyright (C) 2011-2015 Theo Bot

    http://www.activecmdb.org


=head1 DESCRIPTION

    Common security functions

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
 use strict;
=cut

use Exporter;
use strict;
use Logger;
use ActiveCMDB::Common::Constants;

our @ISA = ('Exporter');

our @EXPORT = qw(
	cmdb_check_role
);

=item cmdb_check_role

Check a user against an array of roles

Arguments:
$c		= Catalyst object
@roles	= Array of role names

Return value
$access  = true/false

=cut

sub cmdb_check_role
{
	my($c,@roles) = @_;
	my $access = false;
	push(@roles, 'admin');
	foreach my $role (@roles)
	{
		if ( $c->check_user_roles($role) ) {
			$access = true;
			last;
		}
	}
	
	return $access;
}

1;