package Methods;

=begin nd

    Script: Methods.pm
    ___________________________________________________________________________

    Version 1.0

    Copyright (C) 2011-2015 Theo Bot

    http://www.activecmdb.org


    Topic: Purpose

    Generic mixin library

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

use Config::Settings;
use Data::Dumper;
use Logger;
use Moose::Role;


sub import {
	my($self, $pkg) = @_;
	if ( defined($pkg) ) {
		my $file = sprintf("%s/conf/class/%s.class",$ENV{CMDB_HOME}, $pkg);
		Logger->info("Parsing $file");
		my $config = Config::Settings->new->parse_file($file);
		if ( defined($config->{class}) ) {
			Logger->info("Successfully import $pkg");
				
			return $config->{class};
		} else {
			Logger->warn("Failed to import $pkg");
		}
	} 
}

1;