package ActiveCMDB::Common::Contract;
=head1 MODULE - ActiveCMDB::Common::Contract
    ___________________________________________________________________________

=head1 VERSION

    Version 1.0

=head1 COPYRIGHT

    Copyright (C) 2011-2015 Theo Bot

    http://www.activecmdb.org


=head1 DESCRIPTION

    Common contract functions

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
 use ActiveCMDB::Common::Constants;
 use ActiveCMDB::Object::Contract;
 use ActiveCMDB::Model::CMDBv1;
 use Try::Tiny;
 use strict;
 use Data::Dumper;
=cut

use Exporter;
use Logger;
use ActiveCMDB::Common::Constants;
use ActiveCMDB::Object::Contract;
use ActiveCMDB::Model::CMDBv1;
use Try::Tiny;
use strict;
use Data::Dumper;

our @ISA = ('Exporter');

our @EXPORT = qw(
	get_contract_by_number
	check_contract_number
);

sub get_contract_by_number
{
	my($cn) = @_;
	my $contract = undef;
	
	if ( defined($cn) )
	{
		my $schema = ActiveCMDB::Model::CMDBv1->instance();
		my $row = $schema->resultset("IpDomain")->find(
			{
				contract_number => $cn
			},
			{
				columns => qw/contract_id/
			}
		);
		
		if ( defined($row) )
		{
			$contract = ActiveCMDB::Object::Ipdomain->new(id => $row->contract_id);
			$contract->get_data();	
		}
	} else {
		Logger->warn("Contract number not defined");
	}
	
	return $contract;
}

sub check_contract_number
{
	my($cn) = @_;
	my $contract = undef;
	
	if ( defined($cn) && $cn)
	{
		my $schema = ActiveCMDB::Model::CMDBv1->instance();
		my $row = $schema->resultset("IpDomain")->find(
			{
				contract_number => $cn
			},
			{
				columns => qw/contract_id/
			}
		);
		
		if ( defined($row) )
		{
			$contract = $row->contract_id;
		}
	} else {
		Logger->warn("Contract number not defined");
	}
	
	return $contract;
}