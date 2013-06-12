package ActiveCMDB::Common::Location;

=begin nd

    Script: ActiveCMDB::Common::Location.pm
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
	
	
	
	
=cut

#########################################################################
# Initialize  modules
use Exporter;
use Logger;
use ActiveCMDB::Model::CMDBv1;
use ActiveCMDB::Schema;
use Try::Tiny;
use strict;
use Data::Dumper;

our @ISA = ('Exporter');

our @EXPORT = qw(
	cmdb_get_sites
);
#########################################################################
# Routines

sub cmdb_get_sites
{
	my @sites = ();
	my($rs, $schema, $row);
	#
	# Connect to database
	#
	$schema = ActiveCMDB::Schema->connect(ActiveCMDB::Model::CMDBv1->config()->{connect_info});
	$rs = $schema->resultset("Location")->search(
			undef,
			{
				order_by	=> 'name',
				columns		=> [ qw/location_id name/ ]
			}
	);
	
	while ( $row = $rs->next )
	{
		Logger->debug("Added ". $row->location_id. ' - '.$row->name );
		push(@sites,{ location_id => $row->location_id, name => $row->name } );
	}
	Logger->debug(Dumper(@sites));
	return @sites;
}