package Class::Cisco::NetConfig;

=begin nd

    Script: Class::Cisco::NetConfig.pm
    ___________________________________________________________________________

    Version 1.0

    Copyright (C) 2011-2015 Theo Bot

    http://www.activecmdb.org


    Topic: Purpose

    Download cisco conifguration using the NetConfig mib

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
	
	Download cisco conifguration using the NetConfig mib
	
	
=cut

#
# Initialize modules
#
use Moose::Role;
use Try::Tiny;
use File::Basename;
use Net::SNMP;
use ActiveCMDB::Common::Constants;
use Logger;

sub NetConfig
{
	my($self, $landing) = @_;
	
	#
	# Initialize variables
	#
	my($res, $result, $counter, $file, $mode, $oid, $tftp_file);
	
	Logger->info("Download configuration using NetConfig");
	$result->{filecount} = 1;
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
	
	
	$oid = '.1.3.6.1.4.1.9.2.1.50.'.$landing->{netaddr};

	$res = $self->snmp_set($oid, OCTET_STRING, $tftp_file );
	if ( defined($res) )
	{
		my $filedata = undef;
		$filedata->{filename} = $file;
		$filedata->{filetype} = 'ASCII';
		push(@{$result->{files}},$filedata);
		Logger->info("Cisco NetConfig completed");
		$result->{complete} = true;
	} else {
		Logger->warn("Cisco NetConfig failed: ".$self->snmp_error);
	}
	
	return $result;
}

1;