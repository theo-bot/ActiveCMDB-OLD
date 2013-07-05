package ActiveCMDB::Object::Contract;

=head1 MODULE - ActiveCMDB::Object::Contract
    ___________________________________________________________________________

=head1 VERSION

    Version 1.0

=head1 COPYRIGHT

    Copyright (C) 2011-2015 Theo Bot

    http://www.activecmdb.org


=head1 DESCRIPTION

    ActiveMQ Object definition for contracts

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

=head1 REQUIREMENTS

 use Moose;
 use strict;
 use warnings;
 use Try::Tiny;
 use Logger;
 use Data::Dumper;
 use ActiveCMDB::Object::Vendor;
 
 with 'ActiveCMDB::Object::Methods';
=cut

use Moose;
use strict;
use warnings;
use Try::Tiny;
use Logger;
use Data::Dumper;
use ActiveCMDB::Object::Vendor;

=head1 ACCESSORS

=head2 id
Contract id
=cut
has 'id'	=> (
	is	=> 'ro',
	isa	=> 'Int'
);

=head2 number
Contract number as it states on the "paper" contract
=cut
has 'number' => (
	is	=> 'rw',
	isa => 'Maybe[Str]'
);

=head2 descr
Description of the agreement. For example the scope of the contract
=cut
has	'descr' => (
	is	=> 'rw',
	isa	=> 'Maybe[Str]'
);

=head2 vendor_id
Unique id of the vendor/partner
=cut
has 'vendor_id' => (
	is		=> 'rw',
	isa		=> 'Int',
	default	=> 0
);
=head2 start_date
Start date of the agreement
=cut
has 'start_date' => (
	is	=> 'rw',
	isa	=> 'Maybe[Str]'
);

=head2 end_date
End date of the agreement
=cut
has 'end_date' => (
	is	=> 'rw',
	isa	=> 'Maybe[Str]'
);

=head2 service_hours
Description of the servicecing hours like 7*24 or 5*8 
=cut
has 'service_hours' => (
	is		=> 'rw',
	isa		=> 'Str',
	default	=> ''
);

=head2 internal_phone
The phone number of the department which is responsible for the contract. 
=cut
has 'internal_phone' => (
	is		=> 'rw',
	isa		=> 'Str',
	default	=> ''
);
	
=head2 internal_contact
The name of the department of person who is responsible for the contract
=cut
has 'internal_contact' => (
	is 		=> 'rw',
	isa		=> 'Str',
	default	=> ''
);

=head2 details
All other contract details, mabye even entire contract text
=cut
has 'details' => (
	is		=> 'rw',
	isa		=> 'Maybe[Str]',
	default	=> ''
);

=head2 schema

=cut
has 'schema'	=> (
	is 		=> 'rw', 
	isa 	=> 'Object', 
	default => sub { ActiveCMDB::Model::CMDBv1->instance() } 
);

has 'vendor_name' => (
	is		=> 'rw',
	isa		=> 'Maybe[Str]',
	default	=> ''	
);

with 'ActiveCMDB::Object::Methods';

=head1 VARIABLES

=head2 %map
The attribute to database field mappings
=cut

my %map = (
	id				 => 'contract_id',
	number			 => 'contract_number',
	descr			 => 'contract_descr',
	vendor_id		 => 'vendor_id',
	start_date		 => 'start_date',
	end_date		 => 'end_date',
	service_hours	 => 'service_hours',
	internal_phone	 => 'internal_phone',
	internal_contact => 'internal_contact',
	details			 => 'contract_details'
);

=head1 METHODS

=head2 get_data
Get data for the object from storage
=cut

sub get_data
{
	my($self) = @_;
	Logger->info("Fetching data");
	if ( defined($self->id) && $self->id > 0 )
	{
		my $rs = $self->schema->resultset('Contract')->search(
				{
					contract_id	=> $self->id
				},
				{
					join		=> 'vendor',
					'+select'	=> ['vendor.vendor_name'],
					'+as'		=> ['vendor_name'],
				}
		);
		
		if ( defined($rs) && $rs->count > 0 )
		{
			my $row = $rs->next;
			foreach my $attr (keys %map)
			{
				next if ( $attr =~ /^id$/);
				my $field = $map{$attr};
				next unless defined($row->$field);
				if ( $attr =~ /end_date|start_date/ )
				{
					my $date = substr($row->$attr,0,10);
					$self->$attr($date);
					next;
				}
				Logger->debug("Setting $attr to " . $row->$field);
				$self->$attr( $row->$field );
			}
			$self->vendor_name( $row->get_column('vendor_name') );
		}
	} else {
		Logger->warn("contract id not set or zero. " . $self->id);
	}
	
}

sub populate
{
	my($self, $params) = @_;
	
	foreach my $attr (keys %{$params})
	{
		next if ( $attr =~ /^id$/ || !$map{$attr} );
		Logger->debug("Populate $attr to ". $params->{$attr});
		$self->$attr($params->{$attr});
	} 
}

sub save
{
	my($self) = @_;
	my $data = undef;
	
	$data = $self->to_hashref(\%map);
	
	try {
		my $rs = $self->schema->resultset("Contract")->update_or_create( $data );
		if ( ! $rs->in_storage ) {
			$rs->insert;
		}
	} catch {
		Logger->warn("Failed to save contract: " . $_ );
	};
}

#sub vendor_name
#{
#	my ($self) = @_;
	
#	my $vendor = ActiveCMDB::Object::Vendor->new( id => $self->vendor_id );
#	$vendor->find();
	
#	return $vendor->name;
#}

sub service_start
{
	my($self) = @_;
	my($start,undef) = split(/;/, $self->service_hours);
	
	return sprintf("%02d:%02d", int( $start / 60 ), int( $start % 60 ));
}

sub service_end
{
	my($self) = @_;
	my(undef,$end) = split(/;/, $self->service_hours);
	
	return sprintf("%02d:%02d", int( $end / 60 ), int( $end % 60 ));
}
1;