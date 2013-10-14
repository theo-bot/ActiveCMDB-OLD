#!/usr/bin/env perl

=begin nd

    Script: cmdb_importrule.pl
    ___________________________________________________________________________

    Version 1.0

    Copyright (C) 2011-2015 Theo Bot

    http://www.activecmdb.org


    Topic: Purpose

    Import distribution rules

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
use strict;
use warnings;
use ActiveCMDB::Common::Crypto;
use ActiveCMDB::Common::Import;
use ActiveCMDB::Model::Cloud;
use DateTime;
use File::Slurp;
use Getopt::Long;
use Pod::Usage;
use Data::Dumper;
use Try::Tiny;

my $id;
GetOptions(
	"list"		=> sub { list_imports(); },
	"help"		=> sub { pod2usage(1); },
	"start=s"		=> \&do_import
) or pod2usage(2);

sub list_imports
{
	my @res = cmdb_get_imports();
	my($date,$user,$id,$lc);
	format listImport_TOP =
Import ID                            User       Date       Entries
-------------------------------------------------------------------
.
	
format listImport =
@<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< @<<<<<<<<< @<<<<<<<<   @######
$id,                             $user,     $date,      $lc
.
	$~ = 'listImport';
	$^ = 'listImport_TOP';
	foreach ( @res )
	{
		my $dt = DateTime->from_epoch( epoch => $_->{upload_time});
		$id = $_->{id};
		$user = $_->{username};
		$date = sprintf("%s %s",$dt->ymd, $dt->hms );
		$lc = $_->{tally};
		write;
	}
}

sub do_import($)
{
	my(undef,$id) = @_;
	
	print "Importing >$id<\n";
	cmdb_import_start({ id => $id});
}
