package Class::Device::Snmp;

=begin nd

    Script: Class::Device::SNMP.pm
    ___________________________________________________________________________

    Version 1.0

    Copyright (C) 2011-2015 Theo Bot

    http://www.activecmdb.org


    Topic: Purpose

    SNMP Functions mixin library

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

use Moose::Role;
use Net::SNMP;
use Data::Dumper;
use ActiveCMDB::Common::Constants;

sub snmp_get
{
	my($self, $oid) = @_;
	my($result);
	
	if ( !defined($self->comms) || ref $self->comms ne 'Net::SNMP' ) {
		$self->snmp_connect($self->attr->snmp_ro);
	} else {
		Logger->debug("Already connected with " . $self->comms);
	}
	
	if ( defined($self->comms) ) {
		Logger->debug("Requesting oid $oid");
		$result = $self->comms->get_request($oid);
		if ( defined($result) ) {
			Logger->debug(Dumper($result));
			Logger->debug("Request ($oid) complete :" . $result->{$oid});
			#if ( $oid =~ /1\.3\.6.\.1\.3/ ) { exit; }
			return $result->{$oid};
		} else {
			Logger->warn("Request failed");
			return undef;
		}
	} else {
		Logger->warn("Unable to connect to device");
	}
}

sub snmp_nget
{
	my($self, @oids) = @_;
	my($result);
	
	if ( !defined($self->comms) || ref $self->comms ne 'Net::SNMP' ) {
		$self->snmp_connect($self->attr->snmp_ro);
	} 
	
	if ( defined($self->comms) ) {
		Logger->debug("Requesting oid @oids");
		$result = $self->comms->get_request(@oids);
		if ( defined($result) ) {
			Logger->debug("Request complete");
			return $result;
		} else {
			Logger->warn("Request failed");
			return undef;
		}
	} else {
		Logger->warn("Unable to connect to device");
	}
}

sub snmp_table
{
	my($self, $oid) = @_;
	my($result);
	
	#
	# Reset results
	#
	$result = undef;
	
	if ( !defined($self->comms) ) {
		Logger->debug("Communications handle not defined. Reconnecting");
		$self->snmp_connect($self->attr->snmp_ro)
	} 
	
	if ( ref $self->comms ne 'Net::SNMP' ) {
		Logger->debug("Communications handle is of type " . ref $self->comms );
		$self->snmp_connect($self->attr->snmp_ro);
	}
	
	if ( defined($self->comms) && defined($oid) ) {
		Logger->debug("Requesting table $oid");
		$result = $self->comms->get_table($oid);
		if ( defined($result) ) {
			Logger->debug("Request complete ($oid)");
			
		} else {
			Logger->warn("Request failed ($oid)")
		}
	} else {
		Logger->warn("Unable to connect to device for oid: $oid");
	}
	
	return $result;
}

sub snmp_connect
{
	my($self, $community) = @_;
	if ( $self->attr->snmpv eq '1' || $self->attr->snmpv eq '2c' )
	{
		my($result);
		my $mgtaddr = $self->attr->mgtaddress;
		my $port    = $self->attr->snmp_port;
		my $snmpv   = $self->attr->snmpv;
		
		Logger->debug("Connecting to $mgtaddr with snmp $snmpv community $community");
		my($session, $error) = Net::SNMP->session(
									-hostname	=> $mgtaddr,
									-port		=> $port,
									-version	=> $snmpv,
									-community	=> $community,
									-translate	=> [ -timeticks => 0x0 ]
								);
		if ( ! defined($session) ) {
			Logger->warn("Failed to create session :$error");
			return;
		}
		$result = $session->get_request(OID_SYSOBJECTID);
		if ( !defined($result) ) {
			Logger->warn("Failed to get result :". $session->error);
			return
		}
		Logger->debug("Connection established");
		$self->comms($session);
		return true;
	}
	if ( $self->attr->snmpv eq '3' ) 
	{
		
	}
}

sub snmp_set
{
	my($self,$oid, $type, $value) = @_;

	my $res = undef;

	if ( !defined($self->comms) ) {
		Logger->debug("Communications handle not defined. Reconnecting");
		$self->snmp_connect($self->attr->snmp_rw);
		if ( $self->snmp_connect($self->attr->snmp_rw) )
		{
			$self->comms->timeout(10);
		}
	} 
	
	if ( ref $self->comms ne 'Net::SNMP' ) {
		Logger->debug("Communications handle is of type " . ref $self->comms );
		if ( $self->snmp_connect($self->attr->snmp_rw) )
		{
			$self->comms->timeout(10);
		}
	}
	

	if ( defined($oid) && defined($value) && defined($self->comms) )
	{
		Logger->debug("Setting oid: $oid with value: $value");
		$res = $self->comms->set_request($oid, $type, $value);
	}

	return $res;
}

sub snmp_error
{
	my($self) = @_;
	
	if ( ref $self->comms eq 'Net::SNMP' ) {
		return $self->comms->error();	
	}
}

1;