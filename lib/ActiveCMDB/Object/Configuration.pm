package ActiveCMDB::Object::Configuration;

=begin nd

    Script: ActiveCMDB::Object::Configuration.pm
    ___________________________________________________________________________

    Version 1.0

    Copyright (C) 2011-2015 Theo Bot

    http://www.activecmdb.org


    Topic: Purpose

    IP Device Configuration Class

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

#########################################################################
# Initialize  modules

use Moose;
use Try::Tiny;
use Data::Dumper;
use ActiveCMDB::Common::Constants;
use Logger;
use DateTime;
use DateTime::Format::Strptime;

has 'device_id'			=> (is => 'ro', isa => 'Int');
has 'config_id'			=> (is => 'rw', isa => 'Str');
has 'config_date'		=> (is => 'rw', isa => 'Int');
has 'config_checksum'	=> (is => 'rw', isa => 'Str');
has 'config_status'		=> (is => 'rw', isa => 'Int');
has 'config_type'		=> (is => 'rw', isa => 'Str');
has 'config_name'		=> (is => 'rw', isa => 'Str');
has 'config_data'		=> (is => 'rw', isa => 'Str');

# Schema
has 'schema'		=> (
	is		=> 'rw', 
	isa		=> 'Object', 
	default => sub { ActiveCMDB::Model::CMDBv1->instance() } 
);
with 'ActiveCMDB::Object::Methods';

my %map = (
			config_date		=> 'config_date',
			config_checksum	=> 'config_checksum',
			config_status	=> 'config_status',
			config_type		=> 'config_type',
			config_name		=> 'config_name',
			#config_data		=> 'config_data'
		);

my $config = ActiveCMDB::ConfigFactory->instance();
$config->load('cmdb');


sub save
{
	my($self) = @_;
	my($rs, $data);
	
	$data = undef;
	$data->{config_id}		= $self->config_id;
	$data->{device_id}		= $self->device_id;
	$data->{config_date}	= $self->config_date;
	$data->{config_status}	= $self->config_status || 0;
	$data->{config_type}	= $self->config_type;
	$data->{config_name}	= $self->config_name;
	$data->{config_checksum}= $self->config_checksum;
	
	try {
		$rs = $self->schema->resultset("IpConfigData")->update_or_create( $data );
		if ( !$rs->in_storage ) {
			$rs->insert;
		}
		
		$data = undef;
		$data->{config_id} = $self->config_id;
		$data->{config_data} = $self->{config_data};
		
		$rs = $self->schema->resultset("IpConfigObject")->update_or_create( $data );
		if ( !$rs->in_storage ) {
			$rs->insert;
		}
		Logger->info("Configuration saved");
		return true
	} catch {
		Logger->warn("Failed to save configuration data. " . $_);
	}
}

sub get_data {
	my($self) = @_;
	
	if ( defined($self->device_id) && defined($self->config_id) )
	{
		
		try {
			my $row = $self->schema->resultset("IpConfigData")->find({
				device_id => $self->device_id,
				config_id => $self->config_id
			});
			
			if ( defined($row) ) {
				$self->populate($row, \%map);
			}
			return true;
		} catch {
			Logger->warn("Failed to fetch config data for ". $self->device_id . " config id " . $self->config_id . "\n" . $_ );
		}
	}
}

sub get_object {
	my($self) = @_;
	
	if ( defined($self->device_id) && defined($self->config_id) )
	{
		try {
			my $row = $self->schema->resultset("IpConfigObject")->find({
				config_id => $self->config_id
			});
			
			if ( defined($row) ) {
				$self->config_data($row->config_data);
			}
			return $self->config_data;
		} catch {
			Logger->warn("Failed to fetch config data for ". $self->device_id . " config id " . $self->config_id );
		}
	}
}

sub date2str {
	my($self, $fmt) = @_;
	my($strp, $dt);
	
	if ( !defined($fmt) ) {
		$fmt = $config->section('cmdb::default::date_format');
	}
	
	$dt = DateTime->from_epoch( epoch => $self->config_date);
	return $dt->strftime($fmt);
}

sub state2str {
	my($self) = @_;
	
	return $cfg_state->{ $self->config_status };
}

sub data2web {
	my($self) = @_;
	my $data = '';
	if ( $self->config_type eq 'ASCII' ) {
		$data = $self->config_data;
		$data =~ s/\n/\<br\>/g;
	}
	
	return $data
}

1;