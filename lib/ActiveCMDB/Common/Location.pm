package ActiveCMDB::Common::Location;
=head1 MODULE - ActiveCMDB::Common::Location
    ___________________________________________________________________________

=head1 VERSION

    Version 1.0

=head1 COPYRIGHT

    Copyright (C) 2011-2015 Theo Bot

    http://www.activecmdb.org


=head1 DESCRIPTION

    Common site functions

=head1 LICENSE

    This program is free software; you can redistribute it and/or
    modify it under the terms of the GNU General Public License
    as published by the Free Software Foundation; either version 2
    of the License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

=cut

=head1 IMPORTS
 use Exporter;
 use Logger;
 use ActiveCMDB::Model::CMDBv1;
 use Try::Tiny;
 use strict;
 use Data::Dumper;
=cut

use Exporter;
use Logger;
use ActiveCMDB::Model::CMDBv1;
use ActiveCMDB::Object::Location;
use Try::Tiny;
use strict;
use Data::Dumper;

our @ISA = ('Exporter');

our @EXPORT = qw(
	cmdb_get_sites
	get_site_parents
	get_site_by_name
	get_siteid_by_name
	get_siteid_by_name
);

=head1 FUNCTIONS

=head2 cmdb_get_sites

Return an array of locations  
=cut

sub cmdb_get_sites
{
	my @sites = ();
	my($rs, $schema, $row);
	#
	# Connect to database
	#
	$schema = ActiveCMDB::Model::CMDBv1->instance();
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
	#Logger->debug(Dumper(@sites));
	return @sites;
}

sub get_site_parents
{
	my($type_id) = @_;
	my @parents = ();
	my($rs, $schema, $row);
	$schema = ActiveCMDB::Model::CMDBv1->instance();
	$rs = $schema->resultset("Location")->search(
			{
				location_type => { '<' =>  $type_id }
			},
			{
				order_by	=> ['location_type', 'name' ]
			}
	);
	
	if ( defined($rs) )
	{
		while ( $row = $rs->next )
		{
			push(@parents, { location_id => $row->location_id, name => $row->name });
		}
	}
	
	return @parents;
}

sub get_site_by_name
{
	my($sn) = @_;
	my $site = undef;
	
	if ( defined($sn) )
	{
		my $schema = ActiveCMDB::Model::CMDBv1->instance();
		my $row = $schema->resultset("Location")->find(
			{
				name => $sn
			},
			{
				columns => qw/location_id/
			}
		);
		
		if ( defined($row) )
		{
			$site = ActiveCMDB::Object::Location->new(location_id => $row->location_id);
			$site->get_data();	
		}
	} else {
		Logger->warn("Site name not defined");
	}
	
	return $site;
}

sub get_siteid_by_name
{
	my($sn) = @_;
	my $site = undef;
	
	if ( defined($sn) )
	{
		my $schema = ActiveCMDB::Model::CMDBv1->instance();
		my $row = $schema->resultset("Location")->find(
			{
				name => $sn
			},
			{
				columns => qw/location_id/
			}
		);
		
		if ( defined($row) )
		{
			$site = $row->location_id;	
		}
	} else {
		Logger->warn("Site name not defined");
	}
	
	return $site;
}

1;