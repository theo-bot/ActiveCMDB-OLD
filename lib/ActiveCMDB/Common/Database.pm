package ActiveCMDB::Common::Database;
=head1 MODULE - ActiveCMDB::Common::Database
    ___________________________________________________________________________

=head1 VERSION

    Version 1.0

=head1 COPYRIGHT

    Copyright (C) 2011-2015 Theo Bot

    http://www.activecmdb.org


=head1 DESCRIPTION

    Provide database information for objects

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

=head1 METHODS

=head2 connect_info
Return associative config data for the database connection

Returns
$connect_info	-  {
			dsn => 'dbi:' . $dbinfo->{dbtype} . ':' . $dbinfo->{dbname},
			user => $dbinfo->{dbuser},
			password => $dbinfo->{dbpass},
		}
=cut
sub connect_info {
	my($self) = @_;
	
	my $dbinfo = $self->{config}->section('cmdb::database');
	my $connect_info = {
		dsn => 'dbi:' . $dbinfo->{dbtype} . ':' . $dbinfo->{dbname},
		user => $dbinfo->{dbuser},
		password => $dbinfo->{dbpass},
	};
	
	return $connect_info;
}

1;