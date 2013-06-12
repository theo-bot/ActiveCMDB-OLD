#!/usr/bin/env perl

=begin nd

    Script: cmdb_genkey.pl
    ___________________________________________________________________________

    Version 1.0

    Copyright (C) 2011-2015 Theo Bot

    http://www.activecmdb.org


    Topic: Purpose

    Generate encryption keys

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
	
	This script genrates encryption keys
	

=cut

use v5.16.0;
use ActiveCMDB::Common::Crypto;
use Getopt::Long;

my $keyname = undef;

GetOptions(
			'name=s'	=> \$keyname
		  );

if ( defined($keyname) && length($keyname) > 4 ) 
{		  
	cmdb_genkey($keyname);
} else {
	print "Invalid keyname.\n";
}

exit;