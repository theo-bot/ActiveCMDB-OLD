package ActiveCMDB::Object::Endpoint;

=begin nd

    Script: ActiveCMDB::Object::Endpoint.pm
    ___________________________________________________________________________

    Version 1.0

    Copyright (C) 2012-2013 Theo Bot

    http://www.activecmdb.org


    Topic: Purpose

    ActiveCMDB::Object::Endpoint class definition

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
use ActiveCMDB::Common;
use ActiveCMDB::Model::CMDBv1;
use ActiveCMDB::Object::Endpoint::Message;

has 'id'			=> (is => 'rw', isa => 'Int|Undef');
has 'name'			=> (is => 'rw', isa => 'Str');
has 'method'		=> (is => 'rw', isa => 'Str');
has 'active'		=> (is => 'rw', isa => 'Bool');
has 'dest_in'		=> (is => 'rw', isa => 'Str|Undef');
has 'dest_out'		=> (is => 'rw', isa => 'Str|Undef');
has 'user'			=> (is => 'rw', isa => 'Str|Undef');
has 'password'		=> (is => 'rw', isa => 'Str|Undef');
has 'encrypt'		=> (is => 'rw', isa => 'Bool');
has 'network'		=> (is => 'rw', isa => 'Str|Undef');
has 'subjects'		=> (is => 'rw', isa => 'HashRef|Undef', default => sub { {} });


has 'schema'			=> (is => 'rw', isa => 'Object', default => sub { ActiveCMDB::Model::CMDBv1->instance(); } );
with 'ActiveCMDB::Object::Methods';

my %map = (
	id			=> 'ep_id',
	name		=> 'ep_name',
	method		=> 'ep_method',
	active		=> 'ep_active',
	user		=> 'ep_user',
	password	=> 'ep_password',
	encrypt		=> 'ep_encrypt',
	dest_in		=> 'ep_dest_in',
	dest_out	=> 'ep_dest_out',
	network		=> 'ep_network_data',
);

sub get_data
{
	my($self) = @_;
	
	if ( defined($self->id) && $self->id > 0 )
	{
		Logger->info("Fetching data for distribution endpoint " . $self->id );
		try {
			my $row = $self->schema->resultset("DistEndpoint")->find( { ep_id => $self->id } );
			if ( defined($row) ) {
				$self->populate($row, \%map);
			}
			
			my $rs = $self->schema->resultset("DistEpMessage")->search(
				{
					ep_id => $self->id
				},
				{
					columns => qw/subject/
				}
			);
			$row = undef;
			Logger->info("Found ".$rs->count." messages");
			if ( $rs->count > 0 ) 
			{
				while ( $row = $rs->next )
				{
						$self->subjects->{ $row->subject } = ActiveCMDB::Object::Endpoint::Message->new(id => $self->id, subject => $row->subject);
						$self->subjects->{ $row->subject }->get_data();				
				}
			}
			 
		} catch {
			Logger->warn("Failed to fetch endpoint data for ". $self->id . ' ' . $_);
		}
	} elsif ( defined($self->name) ) {
		Logger->info("Fetching data for distribution endpoint " . $self->name );
		try {
			my $row = $self->schema->resultset("DistEndpoint")->find( { ep_name => $self->name } );
			if ( defined($row) ) {
				$self->populate($row, \%map);
			}
			
			my $rs = $self->schema->resultset("DistEpMessage")->search(
				{
					ep_id => $self->id
				},
				{
					columns => qw/subject/
				}
			);
			$row = undef;
			Logger->info("Found ".$rs->count." messages");
			if ( $rs->count > 0 ) 
			{
				while ( $row = $rs->next )
				{
						$self->subjects->{ $row->subject } = ActiveCMDB::Object::Endpoint::Message->new(id => $self->id, subject => $row->subject);
						$self->subjects->{ $row->subject }->get_data();				
				}
			}
			 
		} catch {
			Logger->warn("Failed to fetch endpoint data for ". $self->id . ' ' . $_);
		}
	}
}

sub save 
{
	my($self) = @_;
	
	try {
		my $data = $self->to_hashref(\%map);
		Logger->debug(Dumper($data));
		my $res = $self->schema->resultset("DistEndpoint")->update_or_create($data);
		
		
		if ( !defined($self->id) || $self->id == 0 ) {
			my $row = $self->schema->resultset("DistEndpoint")->find({ ep_name => $self->name });
			if ( defined($row) ) {
				$self->id( $row->ep_id );
			}
		}
		Logger->info("Saving endpoint messages for endpoint id " . $self->id);
		
		
	} catch {
		Logger->warn("Failed to save ep data for "  . $_);
	}
}

sub map {
	%map;
}