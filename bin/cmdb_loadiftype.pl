#!/usr/bin/env perl

=begin nd

    Script: cmdb_loadiftype.pl
    ___________________________________________________________________________

    Version 1.0

    Copyright (C) 2011-2015 Theo Bot

    http://www.activecmdb.org


    Topic: Purpose

    Create conversions from IANA iftype files

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

use v5.16.0;
use Logger;
use ActiveCMDB::Common::Conversion;
use strict;

my $file = sprintf("%s/var/mibs/IANA/ianaiftype-mib", $ENV{CMDB_HOME});
open(FH, "<", $file) or die "Unable to open mib file";
my $in = 0;
while ( <FH> )
{
	if ( /IANAifType ::= TEXTUAL-CONVENTION/ ) { $in++ }
	if ( $in && /\{/ ) { $in++ }
	if ( $in == 2 && /(.+)\((\d+)\)/ ) {
		my $n = $1;
		my $v = $2;
		my $n =~ s/^\s+//;
		cmdb_add_conversion('ifType', $v, $n);
	}
	if ( $in == 2 && /\}/ ) { $in = 0; }
}

exit;