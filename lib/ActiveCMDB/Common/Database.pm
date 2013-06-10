package ActiveCMDB::Common::Database;

=begin nd

    Script: ActiveCMDB::Common::Database.pm
    ___________________________________________________________________________

    Version 1.0

    Copyright (C) 2012-2013 Theo Bot

    http://www.activecmdb.org


    Topic: Purpose

    Provide database information for objects

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

	Topic: Description
	
	This module performs actions on the conversions table
	
	
=cut

use Data::Dumper;

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