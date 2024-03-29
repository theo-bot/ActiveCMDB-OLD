package ActiveCMDB::Object::Device;


=head1 ActiveCMDB::Object::Device.pm
    ___________________________________________________________________________

=head1 Version 1.0

=head1 Copyright
    Copyright (C) 2011-2015 Theo Bot

    http://www.activecmdb.org


=head1 Description

    ActiveCMDB::Object::Device class definition

=head1 License

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
use Data::Dumper;
use DateTime;
use Logger;
use ActiveCMDB::Common::Constants;
use ActiveCMDB::Object::Journal;
use ActiveCMDB::Object::Configuration;
use ActiveCMDB::Object::Ipdomain;

use constant OBJECT => 1;
use constant DOMAIN => 2;

#
# Define custom types
#
enum 'Tof' => [(0, 1)];	# True of False
enum 'SnmpVer' => [(1, 2, 3)];
enum 'Proto1'  => [('md5', 'sha')];
enum 'Proto2'  => [('des', 'aes')];
#
# Define attributes
#
has 'device_id'		=> (is => 'rw', isa => 'Int');
has 'hostname'		=> (is => 'rw',	isa => 'Str');
has 'mgtaddress'	=> (is => 'rw', isa => 'Str');
has 'sysobjectid'	=> (is => 'rw',	isa => 'Maybe[Str]');
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
has 'contract_id'	=> (is => 'rw', isa => 'Int', default => 0);
has 'os_type'		=> (is => 'rw', isa => 'Str', default => '');
has 'os_version'	=> (is => 'rw', isa => 'Str', default => '');
has 'domain_id'		=> (is => 'rw', isa => 'Maybe[Int]');
# Security attributes
has 'snmp_ro'		=> (is => 'rw', isa => 'Str', trigger => \&_security_source );
has 'snmp_rw'		=> (is => 'rw', isa => 'Str', trigger => \&_security_source);
has 'snmpv'			=> (is => 'rw', isa => 'SnmpVer', default => 1, trigger => \&_security_source);
has 'telnet_user'	=> (is => 'rw', isa => 'Str', trigger => \&_security_source);
has 'telnet_pwd'	=> (is => 'rw', isa => 'Str', trigger => \&_security_source);
has 'snmpv3_user'	=> (is => 'rw', isa => 'Str', trigger => \&_security_source);
has 'snmpv3_pass1'	=> (is => 'rw', isa => 'Str', trigger => \&_security_source);
has 'snmpv3_pass2'	=> (is => 'rw', isa => 'Str', trigger => \&_security_source);
has 'snmpv3_proto1'	=> (is => 'rw', isa => 'Proto1', default => 'md5', trigger => \&_security_source);
has 'snmpv3_proto2'	=> (is => 'rw', isa => 'Proto2', default => 'aes', trigger => \&_security_source);
has 'snmp_port'		=> (is => 'rw', isa => 'Int', default => 161);

# Schema
has 'schema'		=> (
	is => 'rw', 
	isa => 'Object', 
	default => sub { ActiveCMDB::Model::CMDBv1->instance() } 
);

#
has 'domain'		=> (is => 'rw', isa => 'Object');
has 'domain_sec'	=> (is => 'rw', isa => 'Tof', default => 0);

my %sec_source = (
	snmp_ro			=> OBJECT,
	snmp_rw			=> OBJECT,
	snmpv			=> OBJECT,
	telnet_user		=> OBJECT,
	telnet_pwd		=> OBJECT,
	snmpv3_user		=> OBJECT,
	snmpv3_pass1	=> OBJECT,
	snmpv3_pass2	=> OBJECT,
	snmpv3_proto1	=> OBJECT,
	snmpv3_proto2	=> OBJECT
);

=head1 Methods

=head2 find

Load device base tables ip_device and ip_device_sec. 
=head3 arguments
 $self - reference to object
 
The device is must be set to the object. The ActiveCMDB::Common::Device 
module contains functions to find devices by ip address or hostname and 
return Device objects 

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
			
			my $domain_sec =undef;
			if ( defined($self->domain_id) ) {
				my $domain = ActiveCMDB::Object::Ipdomain->new(domain_id => $self->domain_id);
				if ( $domain->get_data() )
				{
					$domain_sec = $domain->security( $self->mgtaddress );
				}
			}
			
			# Get security parametrs;
			$row = $self->schema->resultset("IpDeviceSec")->find({ device_id => $self->device_id });
			if ( defined($row) )
			{
				foreach my $key ( keys %sec_source )
				{
					my $attr = $key;
					next if ( $attr =~ /schema|device_id|configtime/ );
					if ( $row->can($attr) && defined($row->$attr) ) {
						$self->$attr($row->$attr);
						$sec_source{$attr} = OBJECT;
					} else { 
						if ( defined($domain_sec) && defined($domain_sec->$attr) ) {
							$self->$attr( $domain_sec->$attr );
							$sec_source{$attr} = DOMAIN;
						}
					}
				}
			}
			# End security parameters
			return true;
			# Device loaded 
		}
		
	}
}

=head2 get_data

This is an alias for find

=cut

sub get_data
{
	my $self = shift;
	return $self->find(@_);
}

=head2 save

Save object data to the data warehouse.  

=cut

sub save {
	my($self) = @_;
	my @colums = ();
	my($rs, $data, $attr);
	
	if ( defined($self->device_id) ) {
		Logger->debug("Saving device_id" . $self->device_id );
	}
	#
	# Verify if the hostname was set and if it is a new device
	#
	if ( (defined($self->device_id) || $self->device_id == 0) && ( !defined($self->hostname) || length($self->hostname) == 0 ) ) {
		my $h = sprintf("NEW%08d", int(rand(99999999)));
		$self->hostname($h);
		$self->added( DateTime->now() );
	}
	
	#
	# Save ip_device table data, which is in IpDevice
	#
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
		Logger->debug(Dumper($data));
		$rs = $self->schema->resultset("IpDevice")->update_or_create( $data );
		if ( ! $rs->in_storage ) {
			$rs->insert;
		}
		if ( ! defined($self->device_id) || $self->device_id == 0 ) {
			
			Logger->debug("Found row " . $rs->device_id);
			if ( $rs->device_id ) {
				$self->device_id($rs->device_id);
			}
			
 		}
	
		# Next save the security attributes to IpDeviceSec 
		my $domain_sec =undef;
		if ( defined($self->domain_id) ) {
			my $domain = ActiveCMDB::Object::Ipdomain->new(domain_id => $self->domain_id);
			if ( $domain->get_data() )
			{
				$domain_sec = $domain->security( $self->mgtaddress );
			}
		}
		@colums = $self->schema->source("IpDeviceSec")->columns;
		$data = undef;
		foreach $attr (@colums)
		{
			next if ( exists $sec_source{$attr} && $sec_source{$attr} == DOMAIN );
			if ( $self->can($attr)  )
			{
				if ( defined($self->$attr)  )
				{
					# TODO: The domain doesn't support the snmpv attribut 
					if ( exists $sec_source{$attr} && $domain_sec->can($attr) && $self->$attr eq $domain_sec->$attr )
					{
						#
						# The domain can handle this security parameter
						#
						$data->{$attr} = undef;
							
					} else {
						#
						# The security parameters differs from the domain,
						# so we store it with the device
						#
						$data->{$attr} = $self->$attr;
					}
				} else {
					#
					# The data was not defined, so the domain will handle it.
					#
					$data->{$attr} = undef;
				}
			}
		}
		
		#
		# Pass the data to the database
		#
		$rs = $self->schema->resultset("IpDeviceSec")->update_or_create( $data );
		if ( ! $rs->in_storage ) {
			$rs->insert;
		}
		
		
		return true;
		
	} catch {
		Logger->warn("Failed to update device." . $_);
		return false;
	}
}

=head2 set_maint

Store maintenance data in the dataware house (IpDeviceMaint). 

=cut

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

=head2 get_maint

Get the current maintenance schedules for this device

=cut

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

=head2 journal

Create a journal entry in the dataware house for the device.

=head3 arguments

 $self	: Reference to object
 $data	: Hash reference with the 
 following keys:
		user	=> user who created the journal
		prio	=> importance of the journal
		date	=> the timestamp that the journal was entered
		text	=> the journal message

=cut

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

=head2 configs

This method returns a list of configuration objects

=cut

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

sub delete
{
	my($self) = @_;
	
	if ( defined($self->device_id) && $self->device_id > 0 )
	{
		my $row = $self->schema->resultset("IpDevice")->find(
				{
					device_id	=> $self->device_id
				}
		);
		
		if ( defined($row) && $row->device_id == $self->device_id )
		{
			Logger->info("Delete device " . $row->hostname);
			$row->delete();
		}
	}
}

=head2 get_deviceid_by_ip

Find the device_id via an management ip address. 

=cut

sub get_deviceid_by_ip
{
	my($self) = @_;
	
	if ( defined($self->mgtaddress) )
	{
		my $row = $self->schema->resultset("IpDevice")->find(
			{
				mgtaddress => $self->mgtaddress
			},
			{
				columns => qw/device_id/
			}
		);
		if ( defined($row) ) {
			return $row->device_id;
		}
	}
	
	return undef;
}

=head2 get_deviceid_by_hostname



=cut

sub get_deviceid_by_hostname
{
	my($self) = @_;
	
	if ( defined($self->hostname) )
	{
		
		my $row = $self->schema->resultset("IpDevice")->find(
			{
				hostname => $self->hostname
			},
			{
				columns => qw/device_id/
			}
		);
		if ( defined($row) ) {
			return $row->device_id;
		}
	}
	
	return undef;
}

=head2 verify_device_object

Verify a device object to avoid data corruption and duplicates

Arguments:
 $device	- ActiveCMDB::Object::Device object	

=cut

sub verify_device_object
{
	my($self) = @_;
	my($result, $reason);
	$result = true;
	
	#
	# If the device id is not present, try to find it via its management address
	
	if ( !defined($self->device_id) && defined($self->mgtaddress()) )
	{
		my $id = $self->get_deviceid_by_ip();
		if ( defined($id) ) {
			Logger->info("Assigned device_id ($id) via ipaddress");
			$self->device_id($id);
		}
	}	
	
	if ( !defined($self->device_id) && defined($self->hostname) )
	{
		my $id = $self->get_deviceid_by_hostname($self->hostname);
		if ( defined($id) ) {
			Logger->info("Assigned device_id ($id) via hostname");
			$self->device_id($id);
		}
	}
}

sub _security_source
{
	my $self = shift;
	my $pkg = __PACKAGE__;
	my @caller = caller(1);
	my $attr = $caller[3];
	$attr =~ s/^.*://;
	if ( $pkg ne $caller[0] )
	{
		Logger->debug("Value of $attr is set outside $pkg");
		if ( exists $sec_source{$attr} ) {
			$sec_source{$attr} = 1;
		} 
	}
}

__PACKAGE__->meta->make_immutable;

1;