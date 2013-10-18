#!/usr/bin/env perl

=begin nd

    Script: cmdb_convert.pl
    ___________________________________________________________________________

    Version 1.0

    Copyright (C) 2011-2015 Theo Bot

    http://www.activecmdb.org


    Topic: Purpose

    Manage conversions

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
	
	This tool manages the conversion in the conversions table
	
	
=cut

use v5.16.0;
use strict;
use Getopt::Long;
use Logger;
use ActiveCMDB::Common::Conversion;

my($add,$delete,$show);
my($name, $from,$to);

#########################################################################
# MAIN PROGRAM
#########################################################################

GetOptions(
			'add'		=> \$add,
			'delete'	=> \$delete,
			'show'		=> \$show,
			'name=s'	=> \$name,
			'from=s'	=> \$from,
			'to=s'		=> \$to,
			'export'	=> \&cmdb_export_conv,
			'help'		=> \&help
		   );

my $test = $add + $delete + $show;
if ( $test != 1 ) {
	exit 1;
}

if ( $add == 1 ) {
	if ( defined($name) && defined($from) && defined($to) )
	{
		$from =~ s/^\"//;
		$from =~ s/\"$//;
		
		cmdb_add_conversion($name, $from, $to);
	} else {
		Logger->warn("Invalid parameters");
	}
}

if ( $delete ) {
	if ( defined($name) && defined($from) )
	{
		cmdb_del_conversion($name, $from);
	}
}

if ( $show ) {
	if ( defined($name) && defined($from) )
	{
		$to = cmdb_convert($name, $from);
		print_header();
		print_row($name, $from, $to);
	}
	if ( defined($name && !defined($from) ) )
	{
		my @rows = cmdb_list_byname($name);
		print_header();
		foreach my $row  ( @rows )
		{
			print_row($name, $row->{key}, $row->{value});
		}
	}
}
#########################################################################
# Sub routines

sub padd_r
{
	my($string, $len) = @_;

	$string .=  ' ' x $len;
	$string = substr($string, 0, $len);

	return $string;
}

sub print_header
{
	printf("Name              |From                            |To\n");
	printf("------------------+--------------------------------+----------------------------------\n");
}

sub print_row
{
	my($name,$from,$to) = @_;
	printf("%s|%s|%s\n",
					padd_r($name,18),
					padd_r($from,32),
					$to
			  );

}

sub getLogfileName
{
	return $ENV{CMDB_HOME}."/var/log/cmdb_conversion.log";
}

sub help
{
	my $here = <<HELP;
Syntax: cmdb_conversion.pl [options]

Options:
-help        - This information
-add         - Add a new conversion
-delete      - Delete a conversion
-show        - Show conversion(s)
-name <name> - Conversion group (add,delete,show)
-from <from> - Value to convert (show,delete)
-to <to>     - Converted value (add)

Options: add, delete and show are mutually exclusive
HELP

	print $here;
}

#########################################################################
# END OF PROGRAM

