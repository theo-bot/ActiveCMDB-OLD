package ActiveCMDB::Object::atEntry;

=begin nd

    Script: ActiveCMDB::Object::atEntry.pm
    ___________________________________________________________________________

    Version 1.0

    Copyright (C) 2011-2015 Theo Bot

    http://www.activecmdb.org


    Topic: Purpose

    ActiveCMDB::Object::atEntry class definition

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
use Try::Tiny;
use Logger;
use Data::Dumper;


has 'device_id'		=> (is => 'ro', isa => 'Int');
has 'atifindex'		=> (is => 'rw',	isa => 'Int');
has 'atphysaddress'	=> (is => 'rw', isa => 'Str');
has 'atnetaddress'	=> (is => 'rw', isa => 'Str');
has 'disco'			=> (is => 'rw', isa => 'Int');
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
	#
	# Get data from database
	#
	try {
		$rs = $self->schema->resultset("IpDeviceAt")->find(
					{
						device_id 		=> $self->device_id,
						atphysaddress	=> $self->atphysaddress,
						atnetaddress	=> $self->atnetaddress
					}
		);
	} catch {
		Logger->warn("Arp entry not found");
	};
	
	if ( defined($rs) )
	{
		foreach my $key ( __PACKAGE__->meta->get_all_attributes )
		{
			my $attr = $key->name;
			next if ($attr =~ /device_id|schema/ );
			$self->$attr($rs->$attr);
		}
	}
}

sub save
{
	my($self) = @_;
	my($data);
	
	Logger->debug("Saving arp entry for " . $self->atphysaddress);
	
	$data = undef;
	
	foreach my $key ( __PACKAGE__->meta->get_all_attributes )
	{
		my $attr = $key->name;
		#Logger->debug(Dumper($data));
		next if ($attr =~ /schema/);
		$data->{$attr} = $self->$attr;
	}
	
	#Logger->debug(Dumper($data));
		
	try {
		my $rs = $self->schema->resultset("IpDeviceAt")->update_or_create( $data );
		if ( ! $rs->in_storage ) {
			$rs->insert;
		}
	} catch {
		Logger->warn("Failed to save arp entry :" . $_);
	};
	
	
}

__PACKAGE__->meta->make_immutable;
1;