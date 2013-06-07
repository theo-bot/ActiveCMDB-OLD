package ActiveCMDB::Object::ifEntry;

=begin nd

    Script: ActiveCMDB::Object::ifEntry.pm
    ___________________________________________________________________________

    Version 1.0

    Copyright (C) 2012-2013 Theo Bot

    http://www.activecmdb.org


    Topic: Purpose

    ActiveCMDB::Object::ifEntry class definition

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
use Logger;
use Data::Dumper;

has 'device_id'			=> ( is => 'ro', isa => 'Int' );
has 'ifindex'			=> ( is => 'ro', isa => 'Int' );
has 'ifdescr'			=> ( is => 'rw', isa => 'Str' );
has 'ifname'			=> ( is => 'rw', isa => 'Str' );
has 'ifalias'			=> ( is => 'rw', isa => 'Str' );
has 'ifspeed'			=> ( is => 'rw', isa => 'Int' );
has 'ifphysaddress'		=> ( is => 'rw', isa => 'Str' );
has 'ifadminstatus'		=> ( is => 'rw', isa => 'Int' );
has 'ifoperstatus'		=> ( is => 'rw', isa => 'Int' );
has 'iflastchange'		=> ( is => 'rw', isa => 'Int' );
has 'ifhighspeed'		=> ( is => 'rw', isa => 'Int' );
has 'iftype'			=> ( is => 'rw', isa => 'Int' );
has 'istrunk'			=> ( is => 'rw', isa => 'Int', default => 0);

has 'disco'				=> ( is => 'rw', isa => 'Int' );
has 'schema'			=> ( is => 'rw', isa => 'Object' );

sub get_data
{
	my($self) = @_;
	my($rs);
	
	if ( !defined($self->schema) ) { 
		$self->schema(ActiveCMDB::Schema->connect(ActiveCMDB::Model::CMDBv1->config()->{connect_info}));
	}
	
	#
	# Get basic data
	# 
	try {
		$rs = $self->schema->resultset("IpDeviceInt")->find(
			{ 
				device_id => $self->device_id,
				ifindex	  => $self->ifindex 
			}
		);
	} catch {
		Logger->warn("Interface not found");
	};
	
	if ( defined($rs ) )
	{
		foreach my $key ( __PACKAGE__->meta->get_all_attributes )
		{
			my $attr = $key->name;
			next if $attr =~ /schema|ifindex|device_id/;
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
	if ( !defined($self->schema) ) { 
		$self->schema(ActiveCMDB::Schema->connect(ActiveCMDB::Model::CMDBv1->config()->{connect_info}));
	}
	
	
	foreach my $key ( __PACKAGE__->meta->get_all_attributes )
	{
		my $attr = $key->name;
		next if $attr =~ /schema/;
		$data->{$attr} = $self->$attr;
	}
	Logger->debug(Dumper($data));
	try {
			my $ifentry = $self->schema->resultset("IpDeviceInt")->update_or_create(
				$data
			);
			
			# Insert the new record, if it wasn't there
			if ( ! $ifentry->in_storage ) {
				$ifentry->insert;
			} 
		} catch {
			Logger->warn("Failed to save interface\n" . $_);	
		}
}

sub ifspeedstr {
	my ($self) = @_;
	my $mul = 1;
	my @short  = ( 'bit/s', 'Kbit/s', 'Mbit/s', 'Gbit/s' );
	my $digits = length("" . ( $self->ifspeed * $mul) );
	my $divm   = 0;
	while (  $digits - $divm * 3 > 4 ) { $divm++; } 
	
	my $divnum = $self->ifspeed * $mul/10 ** ($divm*3);
	my $format = sprintf("%2.1f %s", $divnum, $short[$divm]);
	
	return $format;
	
}
__PACKAGE__->meta->make_immutable;
1;