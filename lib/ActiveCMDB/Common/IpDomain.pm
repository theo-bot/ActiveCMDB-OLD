package ActiveCMDB::Common::IpDomain;
=head1 MODULE - ActiveCMDB::Common::IpDomain
    ___________________________________________________________________________

=head1 VERSION

    Version 1.0

=head1 COPYRIGHT

    Copyright (C) 2011-2015 Theo Bot

    http://www.activecmdb.org


=head1 DESCRIPTION

    Common ipdomain functions

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
 use ActiveCMDB::Model::Cloud;
 use Try::Tiny;
 use strict;
 use Data::Dumper;
=cut

use Exporter;
use Logger;
use ActiveCMDB::Common::Constants;
use ActiveCMDB::Model::CMDBv1;
use Try::Tiny;
use strict;
use Data::Dumper;

our @ISA = ('Exporter');

our @EXPORT = qw(
	cmdb_get_domains
);

sub cmdb_get_domains
{
	my @domains = ();
	my $schema = ActiveCMDB::Model::CMDBv1->instance();
	push(@domains, { domain_name => 'Select domain'});
	
	my $rs = $schema->resultset("IpDomain")->search(
		{
			active => 1
		},
		{
			order_by	=> 'domain_name',
			columns		=> [qw/domain_id domain_name/]
		}
	);
	if ( defined($rs) )
	{
		while ( my $row = $rs->next )
		{
			push(@domains, { domain_id => $row->domain_id, domain_name => $row->domain_name });
		}
	}
	
	return @domains;
}
