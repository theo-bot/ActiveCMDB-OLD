package Class::Cisco::CopyConfig;

=begin nd

    Script: Class::Cisco::CopyConfig.pm
    ___________________________________________________________________________

    Version 1.0

    Copyright (C) 2011-2015 Theo Bot

    http://www.activecmdb.org


    Topic: Purpose

    Download cisco conifguration using the CopyConfig mib

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

	Topic: Description
	
	Download cisco conifguration using the CopyConfig mib
	
	
=cut

use Moose::Role;
use Try::Tiny;
use File::Basename;
use Net::SNMP;
use ActiveCMDB::Common::Constants;
use Logger;

sub CopyConfig
{
	my($self, $landing) = @_;
	
	#
	# Initialize variables
	#
	my($result, $file, $mode, $tftp_file, $rand, $timeout, $res,
		$counter
	);
	my(	$ccCopyProtocol,
		$ccSourceFileType,
		$ccDestFileType,
		$ccServerAddress, 
		$ccFileName,
		$ccEntryStatus,
		$ccEntryState
	);
	
	
	$result = undef;
	
	Logger->info("Downloading config via Cisco CopyConfig mib");
	
	$result->{filenum} = 1;
	$result->{complete} = false;
	@{$result->{files}} = ();
	
	$file = sprintf("%s/%s.conf",$landing->{directory}, $self->attr->hostname);
	$mode = 0666;
	
	# Create file
	open(TMP, ">", $file);
	close(TMP);
	
	# Set right permissions
	chmod $mode, $file;
	$tftp_file = basename($file);
	# Random number to use with Cisco CC mib oids
	#
	$rand = int(rand 999);
	
	$ccCopyProtocol      = '1.3.6.1.4.1.9.9.96.1.1.1.1.2.'.$rand;
    $ccSourceFileType    = '1.3.6.1.4.1.9.9.96.1.1.1.1.3.'.$rand;
    $ccDestFileType      = '1.3.6.1.4.1.9.9.96.1.1.1.1.4.'.$rand;
    $ccServerAddress     = '1.3.6.1.4.1.9.9.96.1.1.1.1.5.'.$rand;
    $ccFileName          = '1.3.6.1.4.1.9.9.96.1.1.1.1.6.'.$rand;
    $ccEntryStatus       = '1.3.6.1.4.1.9.9.96.1.1.1.1.14.'.$rand;
    $ccEntryState        = '1.3.6.1.4.1.9.9.96.1.1.1.1.10.'.$rand;
	$timeout		= 120;
	
	if ( defined($file) && defined($landing->{netaddr}) )
	{
		Logger->debug("Sending configuration to $landing->{hostname} in file $file");
		$res = $self->snmp_set($ccEntryStatus, INTEGER, 5);
		if ( ! defined($res) ) {
			Logger->warn("Failed to set ccEntryStatus");
			return $result;
		}
		$res = $self->snmp_set($ccCopyProtocol, INTEGER, 1);
		if ( !defined($res) ) {
			Logger->warn("Failed to set ccCopyProtocol: ".$self->snmp_error);
			return $result;
		}
		$res = $self->snmp_set($ccSourceFileType, INTEGER, 4);
		if ( !defined($res) ) {
			Logger->warn("Failed to set ccSourceFileType: ".$self->snmp_error);
			return $result;
		}
		$res = $self->snmp_set($ccDestFileType, INTEGER, 1);
		if ( !defined($res) ) {
			Logger->warn("Failed to set ccDestFileType: ".$self->snmp_error);
			return $result;
		}
		$res = $self->snmp_set($ccServerAddress, IPADDRESS, $landing->{netaddr});
		if ( ! defined($res) ) {
			Logger->warn("Failed to set ccServerAddress");
			return $result;
		}
		$res = $self->snmp_set($ccFileName, OCTET_STRING, $tftp_file);
		if ( ! defined($res) ) {
			Logger->warn("Failed to set ccFileName");
			return $result;
		}
		$res = $self->snmp_set($ccEntryStatus, INTEGER, 1);
		if ( ! defined($res) ) {
			Logger->warn("Failed to set ccEntryStatus");
			return $result;
		}

		#
		# Wait for the download result
		#
		$res = $self->snmp_get($ccEntryState);
		$counter = 0;

		while ( $res == 2 && $counter <= $timeout )
		{
			sleep 2;
			$counter += 2;
			$res = $self->snmp_get($ccEntryState);
			if ( !defined($res) ) { $res = 2; }
		}
		if ( defined($res) && $res == 3 ) {
			Logger->debug("\$ccEntryState: $ccEntryState : 3");
			my $filedata = undef;
			$filedata->{filename} = $file;
			$filedata->{filetype} = 'ASCII';
			push(@{$result->{files}},$filedata);
			$result->{complete} = true;
			$self->snmp_set($ccEntryStatus, INTEGER, 6);
		} else {
			if ( defined($res) ) {
				Logger->warn("\$ccEntryState: $ccEntryState : ".$res->{$ccEntryState});
			} else {
				Logger->warn("Failed to get \$ccEntryState");
			}
		}
	} else {
		if ( !defined($file) ) {
			Logger->warn("Filename not defined");
		}
		if ( !defined($landing->{netaddr}) ) {
			Logger->error("TFTP Server not defined")
		}
	}

	return $result;
	
}

1;