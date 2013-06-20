package ActiveCMDB::Common;

=head1 Module - AvtiveCMDB::Common.pm
    ___________________________________________________________________________

=head1 Version 
1.0

=head1 Copyright
    Copyright (C) 2011-2015 Theo Bot

    http://www.activecmdb.org

=head1 Description

    Common System Library

=head1 License

    This program is free software; you can redistribute it and/or
    modify it under the terms of the GNU General Public License
    as published by the Free Software Foundation; either version 2
    of the License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

=cut

use Exporter;
@ISA = ('Exporter');

@EXPORT = qw(
				subst_envvar reftype
			);

=head1 Functions

=head2 subst_envvar

This subroutine replaces all instances of an enviroment variable 
in a string

 Example:
 my $data = subst_envvar('$CMDB_HOME/conf/myfile.txt');
 print $data,"\n";
 
 Results into:
 /opt/ActiveCMDB/conf/myfile.txt
 

=cut

sub subst_envvar {
	$data = shift;
	
	foreach $var (keys %ENV) {
		$data =~ s/\$$var/$ENV{$var}/g;
	}
	
	return $data;
}

=head2 reftype

Returns reference type if it $_[0] is a reference, otherwise
it returns "SCALAR".

=cut

sub reftype
{
   return ref $_[0] ? ref $_[0] : "SCALAR";
}