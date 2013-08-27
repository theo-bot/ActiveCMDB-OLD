package ActiveCMDB::Object::Circuit::FrDlci;

=head1 MODULE - ActiveCMDB::Object::FrDlci.pm
    ___________________________________________________________________________

=head1 VERSION

    Version 1.0

=head1 COPYRIGHT

    Copyright (C) 2011-2015 Theo Bot

    http://www.activecmdb.org


=head1 DESCRIPTION

    Object definition for frame-relay dlci objects

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
use Logger;
use ActiveCMDB::Model::CMDBv1;

has 'device_id'		=> (is => 'ro', isa => 'Int');
has 'ifindex'		=> (is => 'ro', isa => 'Int');
has 'dlci'			=> (is => 'ro', isa => 'Int');
has 'cir'			=> (is => 'rw', isa => 'Int');
has 'burst'			=> (is => 'rw', isa => 'Int');
has 'type'			=> (is => 'rw', isa => 'Maybe[Str]');
has 'disco'			=> (is => 'rw', isa => 'Int', default => 0);

# Schema
has 'schema'		=> (
	is		=> 'rw', 
	isa		=> 'Object', 
	default => sub { ActiveCMDB::Model::CMDBv1->instance() } 
);

with 'ActiveCMDB::Object::Methods';

my %mapper = (
	device_id	=> 'device_id',
	ifindex		=> 'ifIndex',
	dlci		=> 'dlci',
	cir			=> 'minCir',
	burst		=> 'maxBurst',
	type		=> 'type',
	disco		=> 'disco'
);

sub get_data
{
	my($self) = @_;
	
	if ( defined($self->device_id) && defined($self->ifindex) && defined($self->dlci))
	{
		my $row = $self->schema->resultset("IpDeviceIntDlci")->find(
				{
					device_id	=> $self->device_id,
					ifIndex		=> $self->ifindex,
					dlci		=> $self->dlci
				}
		); 
		
		if ( defined($row) )
		{
			$self->cir($row->minCir);
			$self->burst($row->maxBurst);
			$self->type($row->type);
			$self->disco($row->disco);
		}
	}
}

sub save
{
	my($self) = @_;
	
	if ( defined($self->device_id) && defined($self->ifindex) && defined($self->dlci))
	{
		Logger->info("24081453: Saving dlci data");
		my $data = $self->to_hashref(\%mapper);
		Logger->debug(Dumper($data));
		try {
			my $rs = $self->schema->resultset("IpDeviceIntDlci")->update_or_create( $data );
			if ( ! $rs->in_storage ) {
				$rs->insert;
			}
		} catch {
			Logger->warn("Failed to save dlci: " . $_ );
		};
	}
}

sub dlcistr {
	my ($self) = @_;
	my $mul = 1;
	my @short  = ( 'bit/s', 'Kbit/s', 'Mbit/s', 'Gbit/s' );
	my $digits = length("" . ( $self->cir * $mul) );
	my $divm   = 0;
	while (  $digits - $divm * 3 > 4 ) { $divm++; } 
	
	my $divnum = $self->cir * $mul/10 ** ($divm*3);
	my $format = sprintf("%2.1f %s", $divnum, $short[$divm]);
	
	return $format;
	
}

1;