package ActiveCMDB::Common;

=begin nd

    Script: AvtiveCMDB::Common.pm
    ___________________________________________________________________________

    Version 1.0

    Copyright (C) 2011-2015 Theo Bot

    http://www.activecmdb.org


    Topic: Purpose

    Common System Library

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

use Exporter;
@ISA = ('Exporter');

@EXPORT = qw(
				subst_envvar reftype
			);

sub subst_envvar {
	$data = shift;
	
	foreach $var (keys %ENV) {
		$data =~ s/\$$var/$ENV{$var}/;
	}
	
	return $data;
}
sub reftype
{
   return ref $_[0] ? ref $_[0] : "SCALAR";
}