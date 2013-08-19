package ActiveCMDB::Object::ipAdEntry;

=begin nd

    Script: ActiveCMDB::Object::ipAdEntry.pm
    ___________________________________________________________________________

    Version 1.0

    Copyright (C) 2011-2015 Theo Bot

    http://www.activecmdb.org


    Topic: Purpose

    ActiveCMDB::Object::ipAdEntry class definition

    About: License

    This program is free software; you can redistribute it and/or
    modify it under the terms of the GNU General Public License
    as published by the Free Software Foundation; either version 2
    of the License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    Topic: Release information

    $Rev$

=cut

use Moose;
use Moose::Util::TypeConstraints;
use Try::Tiny;
use Net::IP;
use Logger;

enum 'IpType' => (0, 4, 6);

has 'device_id'			=> (is => 'ro',	isa => 'Int');
has 'ipadentifindex'	=> (is => 'rw', isa => 'Int');
has 'ipadentaddr'		=> (is => 'ro',	isa => 'Str');
has 'ipadentnetmask'	=> (is => 'rw', isa => 'Str');
has 'ipadentprefix'		=> (is => 'rw', isa => 'Int');
has 'iptype'				=> (is => 'rw', isa => 'IpType', default => 0);
has 'disco'				=> (is => 'rw', isa => 'Int');

# Schema
has 'schema'		=> (
	is		=> 'rw', 
	isa		=> 'Object', 
	default => sub { ActiveCMDB::Model::CMDBv1->instance() } 
);

sub get_data
{
	my($self) = @_;
	my($rs);
	
	$rs = $self->schema->resultset("IpDeviceNet")->find(
				{
					device_id	=> $self->device_id,
					ipadentaddr	=> $self->ipadentaddr
				}
			);
	
	if ( defined($rs) ) {
		foreach my $key (__PACKAGE__->meta->get_all_attributes )
		{
			my $attr = $key->name;
			next if ($attr =~ /schema/ );
			$self->$attr($rs->$attr);
		}
	}
	
}

=item save

Save ipAdEntry to the database. Parameters:
- ActiveCMDB::ObjectipAdEntry object

=cut

sub save
{
	my($self) = @_;
	my ($ip, $data,$rs);
	if ( !defined($self->iptype) ) {
		#
		# Reset address type
		$self->iptype(0);
	}	
	
	if ( $ip = new Net::IP($self->ipadentaddr) )
	{
		if ( $ip->ip_is_ipv4() ) { $self->iptype(4); }
		if ( $ip->ip_is_ipv6() ) { $self->iptype(6); }
		
		if ( !defined($self->ipadentprefix) && defined($self->ipadentnetmask) ) {
			$ip->mask($self->ipadentnetmask);
			$self->ipadentprefix($ip->prefixlen());
		}
		
		if ( !defined($self->ipadentnetmask) && defined($self->ipadentprefix) ) {
			$ip->prefix($self->ipadentprefix);
			$self->ipadentnetmask($ip->mask());
		}
	}
	
	
	#
	# Create structure for update_create method
	#
	$data = undef;
	foreach my $key ( __PACKAGE__->meta->get_all_attributes )
	{
		my $attr = $key->name;
		next if ( $attr =~ /schema/ );
		$data->{$attr} = $self->$attr;
	} 
	
	#
	# Perform the transaction
	#
	try {
		#Logger->debug(Dumper($data));
		$rs = $self->schema->resultset("IpDeviceNet")->update_or_create($data);
		if ( ! $rs->in_storage ) { $rs->insert }
	} catch {
		Logger->warn("Failed to save ipAdEntry " . $_);
	}
}

1;