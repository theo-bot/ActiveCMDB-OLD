package ActiveCMDB::Common::Vendor;

=head1 MODULE - ActiveCMDB::Common::Vendor
    ___________________________________________________________________________

=head1 VERSION

    Version 1.0

=head1 COPYRIGHT

    Copyright (C) 2011-2015 Theo Bot

    http://www.activecmdb.org


=head1 DESCRIPTION

    Vendor functions

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

=head1 REQUIRED MODULES

 use Exporter;
 use Logger;
 use ActiveCMDB::Model::CMDBv1;
 use ActiveCMDB::Object::Vendor;
 use Try::Tiny;
 use strict;
 use Data::Dumper;

=cut

use Exporter;
use Try::Tiny;
use strict;
use Data::Dumper;
use Logger;
use ActiveCMDB::Schema;
use ActiveCMDB::Object::Vendor;

our @ISA = ('Exporter');

our @EXPORT = qw(
	cmdb_get_vendors
);

=head1 Functions

=head2 cmdb_get_vendors

Get all vendors in a hash

=head3 RETURNS
 %vendors	- Hash containing vendor names and id's

=cut

sub cmdb_get_vendors
{
	my %vendors = ();
	try {
		
		my $schema = ActiveCMDB::Model::CMDBv1->instance();
	
		my $rs = $schema->resultset('Vendor')->search(
				{
				},
				{
					columns	=> [ qw/vendor_id vendor_name/ ]
				}
			);
	
		if ( defined($rs) )
		{
			while ( my $row = $rs->next )
			{
				$vendors{$row->vendor_id} = $row->vendor_name;
			}
		}
	} catch {
		Logger->error("Failed to get vendors:" . $_);
	};
	
	return %vendors;
}