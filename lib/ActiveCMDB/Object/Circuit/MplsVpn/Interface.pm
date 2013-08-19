package ActiveCMDB::Object::Circuit::MplsVpn::Interface;

=head1 MODULE - ActiveCMDB::Object::MplsVpn::Interface.pm
    ___________________________________________________________________________

=head1 VERSION

    Version 1.0

=head1 COPYRIGHT

    Copyright (C) 2011-2015 Theo Bot

    http://www.activecmdb.org


=head1 DESCRIPTION

    Class definition for VRF Interface objects

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

use Moose;
use Try::Tiny;
use Data::Dumper;
use DateTime;
use Logger;
use ActiveCMDB::Model::CMDBv1;

has 'device_id'		=> (is => 'ro', isa => 'Int');
has 'rd'			=> (is => 'ro', isa => 'Str');
has 'ifindex'		=> (is => 'ro', isa => 'Int', default => 0);
has 'disco'			=> (is => 'rw', isa => 'Int', default => 0);


# Schema
has 'schema'		=> (
	is		=> 'rw', 
	isa		=> 'Object', 
	default => sub { ActiveCMDB::Model::CMDBv1->instance() } 
);

my %mapper = (
	device_id	=> 'device_id',
	rd			=> 'vrf_rd',
	ifindex		=> 'ifIndex',
	disco		=> 'disco'
);

with 'ActiveCMDB::Object::Methods';

sub get_data
{
	my($self) = @_;
	
	if ( defined($self->device_id) && defined($self->rd) && defined($self->ifindex) ) 
	{
		my $row = $self->schema->resultset("IpDeviceIntVrf")->find(
					{
						device_id	=> $self->device_id,
						vrf_rd		=> $self->rd,
						ifIndex		=> $self->ifindex
					}
		); 
		if ( defined($row) )
		{
			$self->disco($row->disco);
		}
	}
}

sub save
{
	my($self) = @_;
	
	if ( defined($self->device_id) && $self->device_id > 0 && defined($self->rd) && defined($self->ifindex) )
	{
		my $data = $self->to_hashref(\%mapper);
		try {
			my $rs = $self->schema->resultset("IpDeviceIntVrf")->update_or_create( $data );
			if ( ! $rs->in_storage ) {
				$rs->insert;
			}
		} catch {
			Logger->warn("Failed to save mplsIntVpn: " . $_ );
		}; 
	}
}