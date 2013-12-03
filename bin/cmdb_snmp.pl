#!/usr/bin/env perl


use v5.16.0;
use Getopt::Long;
use Pod::Usage;
use ActiveCMDB::Common::Conversion;

my($export,$help,$add,$delete,$oid,$name,$value,$mibvalue);

GetOptions(
	"export"		=> \$export,
	"help"			=> \$help,
	"add"			=> \$add,
	"delete"		=> \$delete,
	"oid=s"			=> \$oid,
	"name=s"		=> \$name,
	"value=s"		=> \$value,
	"mibvalue=s"	=> \$mibvalue
) or pod2usage(1);

pod2usage(-verbose => 99, -sections => [ qw/NAME SYSOPSIS DESCRIPTION COPYRIGHT/ ]) if $help;

if ( $export ) {
	cmdb_export_snmp();
	exit;
}

if ( $add ) {
	cmdb_snmp_add($oid,$name,$value,$mibvalue);
	exit;
}

if ( $delete ) {
	cmdb_snmp_delete($oid,$value);
	exit;
}


__END__

=head1 NAME

cmdb_snmp.pl - Various snmp related functions

=head1 SYNOPSIS

sample [options] [file ...]

 Options:
  --help brief help message
  --export export snmp translation values
  --add add new snmp mib translation
  
=head1 OPTIONS

=over 8

=item B<-help>

Print a brief help message and exits.

=item B<-export>

Export all values in so the can be imported.

=item B<-add>

Add an snmp mib translation

=head1 DESCRIPTION

B<This program> will read the given input file(s) and do something
useful with the contents thereof.

=head1 COPYRIGHT

Copyright (C) 2011-2015 Theo Bot

http://www.activecmdb.org

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

=back

=cut