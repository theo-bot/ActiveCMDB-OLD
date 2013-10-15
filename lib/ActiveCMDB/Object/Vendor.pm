package ActiveCMDB::Object::Vendor;
=head1 MODULE - ActiveCMDB::Object::Vendor
    ___________________________________________________________________________

=head1 VERSION

    Version 1.0

=head1 COPYRIGHT

    Copyright (C) 2011-2015 Theo Bot

    http://www.activecmdb.org


=head1 DESCRIPTION

    Vendor object class definition

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

 use Moose;
 use Moose::Util::TypeConstraints;
 use Try::Tiny;
 use Logger;
=cut

use Moose;
use Moose::Util::TypeConstraints;
use Try::Tiny;
use Logger;

=head1 ATTRIBUTES

=head2 id

INTEGER, Unique id for vendor
=cut
has 'id'			=> (is => 'rw',	isa => 'Maybe[Int]');

=head2 name

STRING, Vendor name
=cut
has 'name'			=> (is => 'rw', isa => 'Str');
has 'phone'			=> (is => 'rw', isa => 'Str');
has 'support_phone'	=> (is => 'rw', isa => 'Str');
has 'support_email'	=> (is => 'rw', isa => 'Str');
has 'support_www'	=> (is => 'rw', isa => 'Str');
has 'enterprises'	=> (is => 'rw', isa => 'Any');
has 'details'		=> (is => 'rw', isa => 'Any');

# Schema
has 'schema'		=> (
	is => 'rw',
	isa => 'Object', 
	default => sub { ActiveCMDB::Model::CMDBv1->instance(); } 
);

my %map = (
	id				=> 'vendor_id',
	name			=> 'vendor_name',
	phone			=> 'vendor_phone',
	support_phone	=> 'vendor_support_phone',
	support_email	=> 'vendor_support_email',
	support_www		=> 'vendor_support_www',
	enterprises		=> 'vendor_enterprises',
	details			=> 'vendor_details'
);

with 'ActiveCMDB::Object::Methods';

sub find
{
	my ($self) = @_;
	my($row,$attr);
	
	$row = $self->schema->resultset("Vendor")->find({vendor_id => $self->id});
	if ( defined($row) )
	{
		foreach $attr (keys %map)
		{
			my $field = $map{$attr};
			if ( defined($row->$field()) )
			{
				$self->$attr($row->$field());
			}
		}
	}
	
}

sub get_data
{
	my($self) = @_;
	
	return $self->find();
}

sub save 
{
	my($self) = @_;
	
	if ( !defined($self->id) && defined($self->name) )
	{
		my $count = $self->schema->resultset("Vendor")->search({ vendor_name => $self->name })->count;
		if ( $count > 0 )
		{
			Logger->warn("Vendor already exists");
			return;
		}
	}
	
	my $data = $self->to_hashref(\%map);
		
	try {
		Logger->debug("Updating vendor");
		my $vendor = $self->schema->resultset("Vendor")->update_or_create( $data );
		if ( ! $vendor->in_storage ) {
			$vendor->insert;
		}
		
		return('Vendor saved');
	} catch {
		Return("Failed to save ");
		Logger->warn("Failed to save vendor ". $_);
	};
}

sub populate
{
	my($self, $params) = @_;
	
	foreach my $attr (keys %{$params})
	{
		next if ( $attr =~ /^$/ || !$map{$attr} );
		Logger->debug("Populate $attr to ". $params->{$attr});
		$self->$attr($params->{$attr});
	} 
}


1;