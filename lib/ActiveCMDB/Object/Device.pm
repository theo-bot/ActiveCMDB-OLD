package ActiveCMDB::Object::Device;

=begin nd

    Script: ActiveCMDB::Object::Device.pm
    ___________________________________________________________________________

    Version 1.0

    Copyright (C) 2011-2015 Theo Bot

    http://www.activecmdb.org


    Topic: Purpose

    ActiveCMDB::Object::Device class definition

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

#
# Include required modules 
#
use Moose;
use Moose::Util::TypeConstraints;
use Try::Tiny;
use DateTime;
use Logger;
use ActiveCMDB::Common::Constants;
use ActiveCMDB::Object::Journal;
use ActiveCMDB::Object::Configuration;

#
# Define custom types
#
enum 'Tof' => (0, 1);	# True of False
enum 'SnmpVer' => (1, 2, 3);
enum 'Proto1'  => ('md5', 'sha');
enum 'Proto2'  => ('des', 'aes');
#
# Define attributes
#
has 'device_id'		=> (is => 'ro', isa => 'Int');
has 'hostname'		=> (is => 'rw',	isa => 'Str');
has 'mgtaddress'	=> (is => 'rw', isa => 'Str');
has 'sysobjectid'	=> (is => 'rw',	isa => 'Str');
has 'disco'			=> (is => 'rw', isa => 'Str');
has 'sysuptime'		=> (is => 'rw', isa => 'Int');
has 'sysdescr'		=> (is => 'rw', isa => 'Str');
has 'external_id'	=> (is => 'rw', isa => 'Str');
has 'location_id'	=> (is => 'rw', isa => 'Int');
has 'added'			=> (is => 'rw', isa => 'DateTime');
has 'is_critical'	=> (is => 'rw',	isa => 'Tof', default => 1);
has 'is_ssh'		=> (is => 'rw', isa => 'Tof', default => 0);
has 'is_telnet'		=> (is => 'rw', isa => 'Tof', default => 0);
has 'tftpset'		=> (is => 'rw', isa => 'Str', default => 'DEFAULT');
has 'discotime'		=> (is => 'rw', isa => 'Int');
has 'configtime'	=> (is => 'rw', isa => 'Int');
has 'status'		=> (is => 'rw', isa => 'Int');

# Security attributes
has 'snmp_ro'		=> (is => 'rw', isa => 'Str');
has 'snmp_rw'		=> (is => 'rw', isa => 'Str');
has 'snmpv'			=> (is => 'rw', isa => 'SnmpVer', default => 1);
has 'telnet_user'	=> (is => 'rw', isa => 'Str');
has 'telnet_pwd'	=> (is => 'rw', isa => 'Str');
has 'snmpv3_user'	=> (is => 'rw', isa => 'Str');
has 'snmpv3_pass1'	=> (is => 'rw', isa => 'Str');
has 'snmpv3_pass2'	=> (is => 'rw', isa => 'Str');
has 'snmpv3_proto1'	=> (is => 'rw', isa => 'Proto1', default => 'md5');
has 'snmpv3_proto2'	=> (is => 'rw', isa => 'Proto2', default => 'aes');

# Schema
has 'schema'		=> (is => 'rw', isa => 'Object', default => sub { ActiveCMDB::Schema->connect(ActiveCMDB::Model::CMDBv1->config()->{connect_info}) } );


=item find

Load device base tables ip_device and ip_device_sec. 
Parameters
- $self 

=cut

sub find {
	my($self) = @_;
	my($rs1, $rs2,$row);
	
	if ( defined($self->device_id) && $self->device_id > 0 ) 
	{
		$row = $self->schema->resultset("IpDevice")->find({ device_id => $self->device_id} );
		if ( defined($row) )
		{
			
			foreach my $key ( __PACKAGE__->meta->get_all_attributes )
			{
				my $attr = $key->name;
				next if ( $attr =~ /schema|device_id/ );
				if ( $row->can($attr) && defined($row->$attr) ) {
					$self->$attr($row->$attr);
				} 
			}
			
			# Get security parametrs;
			$row = $self->schema->resultset("IpDeviceSec")->find({ device_id => $self->device_id });
			if ( defined($row) )
			{
				foreach my $key ( __PACKAGE__->meta->get_all_attributes )
				{
					my $attr = $key->name;
					next if ( $attr =~ /schema|device_id/ );
					if ( $row->can($attr) && defined($row->$attr) ) {
						$self->$attr($row->$attr);
					}
				}
			}
			# End security parameters
			return true;
			# Device loaded 
		}
		
	}
}

sub get_data
{
	my $self = shift;
	return $self->find(@_);
}
sub save {
	my($self) = @_;
	my @colums = ();
	my($rs, $data, $attr);
	
	# Save ip_device table data, which is in IpDevice
	@colums = $self->schema->source("IpDevice")->columns;
	$data = undef;
	foreach $attr (@colums)
	{
		if ( $self->can($attr) && defined($self->$attr) )
		{
			$data->{$attr} = $self->$attr;
		}
	}
	
	try {
		$rs = $self->schema->resultset("IpDevice")->update_or_create( $data );
		if ( ! $rs->in_storage ) {
			$rs->insert;
		}
	
		# Next save the security attributes to IpDeviceSec 
		@colums = $self->schema->source("IpDeviceSec")->columns;
		$data = undef;
		foreach $attr (@colums)
		{
			if ( $self->can($attr) && defined($self->$attr) )
			{
				$data->{$attr} = $self->$attr;
			}
		}
		$rs = $self->schema->resultset("IpDeviceSec")->update_or_create( $data );
		if ( ! $rs->in_storage ) {
			$rs->insert;
		}
		
		return true;
		
	} catch {
		Logger->warn("Failed to update device.");
		return false;
	}
}

sub set_maint
{
	my($self, $maint) = @_;
	my($rs);
	
	if ( ! defined($maint) )
	{
		$rs = $self->schema->resultset("IpDeviceMaint")->search(
			{
				device_id => $self->device_id
			}
		);
		$rs->delete();
	} else {
		$rs = $self->schema->resultset("IpDeviceMaint")->search(
			{
				device_id => $self->device_id,
				maint_id  => { 'not in' => [ split(/\,/, $maint) ]}
			}
		);
		$rs->delete;
		for my $id ( split(/\,/, $maint) )
		{
			my $data = undef;
			$data->{device_id} = $self->device_id;
			$data->{maint_id}  = $id;
			$self->schema->resultset("IpDeviceMaint")->update_or_create( $data );
		}
	}
}

sub get_maint
{
	my($self) = @_;
	my($rs);
	my @schedules = ();
	
	$rs = $self->schema->resultset("IpDeviceMaint")->search( 
		{ 
			device_id	=> $self->device_id 
		},
		{
			columns 	=> qw/maint_id/
		}
	);
	if ( defined($rs) )
	{
		while( my $row = $rs->next )
		{
			push(@schedules, $row->maint_id);
		} 
	}
	
	return @schedules;
}

sub journal {
	my($self, $data) = @_;
	
	if ( defined($data) ) {
		my $journal = ActiveCMDB::Object::Journal->new(device_id => $self->device_id);
		$journal->user($data->{user});
		$journal->prio($data->{prio});
		$journal->date($data->{date});
		$journal->data($data->{text});
		
		$journal->save();
	}
}

sub configs {
	my ($self) = @_;
	my @cfgdata = ();
	
	if ( $self->device_id > 0 ) {
		my $res = $self->schema->resultset("IpConfigData")->search(
				{
					device_id => $self->device_id,
				},
				{
					order_by	=> 'config_date',
					columns		=> 'config_id'
				}
		);
		if ( defined($res) )
		{
			while (my $row = $res->next )
			{
				my $cfg = ActiveCMDB::Object::Configuration->new(device_id => $self->device_id, 
																 config_id => $row->config_id
																 );
				$cfg->get_data();
								
				push(@cfgdata, $cfg);
			}			
		}
	}
	
	return @cfgdata;
}

__PACKAGE__->meta->make_immutable;

1;