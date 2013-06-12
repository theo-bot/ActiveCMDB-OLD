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
use ActiveCMDB::Dist::Loader;
use ActiveCMDB::Object::Distrule;
use File::Slurp;
use Getopt::Long;
use Pod::Usage;
use Data::Dumper;

my $name;
my $rule;
GetOptions(
	"name=s"	=> \$name,
	"help"		=> sub { pod2usage(1); }
) or pod2usage(2);

if ( ! defined($name) ) { pod2usage("$0 - Missing arguments"); }
my $cloud = ActiveCMDB::Model::Cloud->new();
$cloud->bucket('CmdbDistRules');

my $rulefile = sprintf("%s/%s.rule", get_rules_dir(), $name);
if ( -r $rulefile )
{
	my $data = read_file( $rulefile );
	if ( defined($data) )
	{
		print $data,"\n";
		my $object = $cloud->get({ key => $name });
		if ( $object->exists == 1 )
		{
			Logger->info("Updating rule");
			$cloud->update( { key => $name, value => $data }  );
			Logger->info("Object updated");
		} else {
			Logger->info("Creating new rule");
			$cloud->create( { key => $name, value => $data } );
			Logger->info("Object created");
		}
	}
} else {
	die "Unable to read rulefile.\n";
}

print "Rule imported\n";

exit 0;
__END__

=pod

=head1 NAME

cmdb_importrule.pl - Import distrubution rule to distrubuted storage	

=head1 SYNOPSIS
	./cmdb_importrule.pl [OPTION]
	
Options:
	--help	
			This explanation
			
	--name 
			Import corresponding rule file. 

=head1 EXAMPLE

	Import the file cisco.rule from \$CMDB_HOME/conf/dist
	./cmdb_importrule.pl --name cisco
	
=cut
