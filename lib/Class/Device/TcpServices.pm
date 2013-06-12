package Class::Device::TcpServices;

=begin nd

    Script: Class::Device::Ipmib.pm
    ___________________________________________________________________________

    Version 1.0

    Copyright (C) 2011-2015 Theo Bot

    http://www.activecmdb.org


    Topic: Purpose

    CMDB::Device::Arp class definition

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
# Initialize required modules
#
use Moose::Role;
use Try::Tiny;
use Logger;
use ActiveCMDB::Object::Device;
use ActiveCMDB::Common::Constants;

my %tcp_services = (
		'is_ssh'	=> 22,
		'is_telnet'	=> 23,
);


sub discover_tcpservices
{
	my($self, $data) = @_;
	
	my $object = ActiveCMDB::Object::Device->new(device_id => $self->device_id);
	$object->find();
	
	foreach my $service (keys %tcp_services)
	{
		$object->$service( $self->_testservice($tcp_services{$service}) );
	}
	
	return $object;
}

sub save_tcpservices
{
	my($self, $data) = @_;
	
	Logger->debug("Saving tcp services data");
	$data->save();
}


sub _testservice
{
	my($self, $service) = @_;
	my($timeout, $ip, $socket, $result);
	
	
	$result = false;
	$ip = $self->attr->mgtaddress;
	Logger->info("Testing service $service with ip $ip");
	try {
		Logger->debug("Setting signal handler");
		local $SIG{ALRM} = sub {return 0};
		Logger->info("Setting alarm to ".TCP_TIMEOUT);
		alarm TCP_TIMEOUT;
		if ($socket = IO::Socket::INET->new(Proto    => "tcp", PeerAddr => "$ip", PeerPort => "$service" ) )
		{
			# Disable alarm
			alarm(0);
			
			# Set the result
			$result = true;
			
			# Close the socket
			$socket->close();
			
			Logger->info("Successfully connected to port $service ");
		} else {
			# Disable alarm
			alarm(0);
			
			# Set result
			$result = false;
			
			Logger->warn("Failed to connect to port $service");
		}
	} catch {
		Logger->warn("Test failed: " . $_);
		alarm(0);
		$result = false;
	};
	
	return $result;
}
