package ActiveCMDB::Object::Circuit::MplsVpn;

=head1 MODULE - ActiveCMDB::Object::Vrf.pm
    ___________________________________________________________________________

=head1 VERSION

    Version 1.0

=head1 COPYRIGHT

    Copyright (C) 2011-2015 Theo Bot

    http://www.activecmdb.org


=head1 DESCRIPTION

    Class definition for VRF objects

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
use ActiveCMDB::Object::Circuit::MplsVpn::Interface;

has 'device_id'		=> (is => 'ro', isa => 'Int');
has 'rd'			=> (is => 'ro', isa => 'Str');
has 'name'			=> (is => 'rw', isa => 'Maybe[Str]');
has 'status'		=> (is => 'rw', isa => 'Int', default => 0);
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
	name		=> 'vrf_name',
	status		=> 'vrf_status',
	disco		=> 'disco'
);

with 'ActiveCMDB::Object::Methods';

sub get_data
{
	my($self) = @_;
	
	if ( defined($self->device_id) && defined($self->rd) ) 
	{
		my $row = $self->schema->resultset("IpDeviceVrf")->find(
					{
						device_id	=> $self->device_id,
						vrf_rd		=> $self->rd
					}
		); 
		if ( defined($row) )
		{
			foreach my $key (%mapper) {
				my $attr = $mapper{$key};
				if ( $row->can($attr) && $self->meta->get_attribute( $key )->get_write_method() ) 
				{ 
					$self->$key( $row->$attr() );
				}
			}
		}
	}
}

sub save
{
	my($self) = @_;
	
	if ( defined($self->device_id) && $self->device_id > 0 && defined($self->rd) )
	{
		my $data = $self->to_hashref(\%mapper);
		try {
			my $rs = $self->schema->resultset("IpDeviceVrf")->update_or_create( $data );
			if ( ! $rs->in_storage ) {
				$rs->insert;
			}
		} catch {
			Logger->warn("Failed to save mplsVpn: " . $_ );
		}; 
	}
}

sub interfaces
{
	my($self, @interfaces) = @_;
	
	if ( @interfaces )
	{
		foreach my $ifIndex (@interfaces)
		{
			my $vpnInt = ActiveCMDB::Object::Circuit::MplsVpn::Interface->new(
				device_id => $self->device_id,
				ifindex		=> $ifIndex,
				rd			=> $self->rd,
				disco		=> $self->disco
			);
			$vpnInt->save();
		}
		my $rs = $self->schema->resultset("IpDeviceIntVrf")->search(
			{
				device_id	=> $self->device_id,
				vrf_rd		=> $self->rd,
				disco		=> { '!=' => $self->disco }
			}
		);
		if ( defined($rs) )
		{
			while ( my $row = $rs->next ) 
			{
				$row->delete;
			}
		}
	}
	
	@interfaces = ();
	my $rs = $self->schema->resultset("IpDeviceIntVrf")->search(
		{
			device_id	=> $self->device_id,
			vrf_rd		=> $self->rd
		}
	);
	
	if ( defined($rs) ) {
		while ( my $row = $rs->next )
		{
			my $vpnInt = ActiveCMDB::Object::ifEntry->new(device_id => $self->device_id, ifindex => $row->ifIndex );
				
			$vpnInt->get_data();
			push(@interfaces, $vpnInt);
		}
	}
	
	return @interfaces;
}
1;