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
use ActiveCMDB::Schema;
use Try::Tiny;
use strict;
use Data::Dumper;

our @ISA = ('Exporter');

our @EXPORT = qw(
	cmdb_get_sites
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