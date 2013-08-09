package ActiveCMDB::Object::VLan;

=head1 MODULE - ActiveCMDB::Object::VLan.pm
    ___________________________________________________________________________

=head1 VERSION

    Version 1.0

=head1 COPYRIGHT

    Copyright (C) 2011-2015 Theo Bot

    http://www.activecmdb.org


=head1 DESCRIPTION

    Class definition for vlan objects

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

has 'device_id'		=> (is => 'rw', isa => 'Int', default => 0);
has 'vlan_id'		=> (is => 'rw', isa => 'Int', default => 0);
has 'name'			=> (is => 'rw', isa => 'Str|Undef');
has 'type'			=> (is => 'rw', isa => 'Str|Undef');
has 'status'		=> (is => 'rw', isa => 'Str|Undef');
has 'disco'			=> (is => 'rw', isa => 'Int', default => 0);

# Schema
has 'schema'		=> (
	is		=> 'rw', 
	isa		=> 'Object', 
	default => sub { ActiveCMDB::Model::CMDBv1->instance() } 
);

my %mapper = (
	device_id	=> 'device_id',
	vlan_id		=> 'vlan_id',
	name		=> 'name',
	status		=> 'status',
	disco		=> 'disco'
);

with 'ActiveCMDB::Object::Methods';

sub get_data
{
	my($self) = @_;
	my($row);
	
	if ( $self->device_id >0 && $self->vlan_id > 0 ) {
		$row = $self->schema->resultset("IpDeviceVlan")->find(
						{
							device_id	=> $self->device_id,
							vlan_id		=> $self->vlan_id
						}
		);
		if ( defined($row) ) {
			foreach my $key (keys %mapper)
			{
				my $attr = $mapper{$key};
				if ( $row->can($attr) ) { $self->$key($row->$attr) }
			}
		}
	}
}

sub save {
	my($self) = @_;
	
	Logger->info("08071622: Saving vlan data");
	
	my $data = $self->to_hashref(\%mapper);
	Logger->debug(Dumper($data));
	try {
		my $rs = $self->schema->resultset("IpDeviceVlan")->update_or_create( $data );
		if ( ! $rs->in_storage ) {
			$rs->insert;
		}
	} catch {
		Logger->warn("Failed to save vlan: " . $_ );
	}
}

sub interfaces {
	my($self) = @_;
	my @interfaces = ();
	
	my $rs = $self->schema->resultset("IpDeviceIntVlan")->search(
		{
			device_id	=> $self->device_id,
			vlan_id		=> $self->vlan_id
		},
		{
			columns		=> [ qw/ifindex/ ],
			order_by	=> 'ifindex'
		}
	);
	
	if ( defined($rs) )
	{
		while( my $row = $rs->next )
		{
			my $int = ActiveCMDB::Object::ifEntry->new(device_id => $self->device_id, ifindex => $row->ifindex );
			$int->get_data();
			push(@interfaces, $int);
		}
	}
	
	return @interfaces;
}

1;