package ActiveCMDB::Object::entPhysicalEntry;

=begin nd

    Script: ActiveCMDB::Object::entPhysicalEntry.pm
    ___________________________________________________________________________

    Version 1.0

    Copyright (C) 2011-2015 Theo Bot

    http://www.activecmdb.org


    Topic: Purpose

    ActiveCMDB::Object::entPhysicalEntry class definition

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

has 'device_id'					=> (is => 'ro', isa => 'Int');
has 'entphysicalindex'			=> (is => 'ro', isa => 'Int');
has 'entphysicaldescr'			=> (is => 'rw',	isa => 'Str');
has 'entphysicalvendortype'		=> (is => 'rw', isa => 'Str');
has 'entphysicalcontainedin'	=> (is => 'rw', isa => 'Int');
has 'entphysicalclass'			=> (is => 'rw', isa => 'Int');
has 'entphysicalname'			=> (is => 'rw', isa => 'Str');
has 'entphysicalhardwarerev'	=> (is => 'rw',	isa => 'Str');
has 'entphysicalfirmwarerev'	=> (is => 'rw', isa => 'Str');
has 'entphysicalsoftwarerev'	=> (is => 'rw', isa => 'Str');
has 'entphysicalserialnum'		=> (is => 'rw', isa => 'Str');
has 'ifindex'					=> (is => 'rw', isa => 'Int');
has 'disco'						=> (is => 'rw', isa => 'Int');

# Schema
has 'schema'		=> (
	is		=> 'rw', 
	isa		=> 'Object', 
	default => sub { ActiveCMDB::Model::CMDBv1->instance() } 
);
has 'icon'						=> (is => 'rw', isa => 'Any');

sub get_data
{
	my($self) = @_;
	my($rs);
	
	#
	# Get basic data
	# 
	try {
		$rs = $self->schema->resultset("IpDeviceEntity")->find(
			{ 
				device_id			 => $self->device_id,
				entphysicalindex	 => $self->entphysicalindex 
			}
		);
	} catch {
		Logger->warn("Entity not found\n" . $_);
	};
	
	if ( defined($rs ) )
	{
		foreach my $key ( __PACKAGE__->meta->get_all_attributes )
		{
			my $attr = $key->name;
			next if $attr =~ /schema|entphysicalindex|device_id|icon/;
			if ( defined($rs->$attr) )
			{
				$self->$attr($rs->$attr);
			}
		}
	}
}


sub save
{
	my($self) = @_;
	my($data);
	
	$data = undef;
	
	
	foreach my $key ( __PACKAGE__->meta->get_all_attributes )
	{
		my $attr = $key->name;
		next if $attr =~ /schema|icon/;
		$data->{$attr} = $self->$attr;
	}
	
	try {
			my $ifentry = $self->schema->resultset("IpDeviceEntity")->update_or_create(
				$data
			);
			
			# Insert the new record, if it wasn't there
			if ( ! $ifentry->in_storage ) {
				$ifentry->insert;
			} 
		} catch {
			Logger->warn("Failed to save entity\n" . $_);	
		}
}

__PACKAGE__->meta->make_immutable;
1;