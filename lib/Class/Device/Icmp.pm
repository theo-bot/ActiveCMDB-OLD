package Class::Device::Icmp;

=begin nd

    Script: Class::Device::icmp.pm
    ___________________________________________________________________________

    Version 1.0

    Copyright (C) 2011-2015 Theo Bot

    http://www.activecmdb.org


    Topic: Purpose

    Icmp discovery class definition

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
use Switch;
use ActiveCMDB::Common::Constants;
use Logger;

sub ping 
{
	my($self) = @_;
	my($command);
	
	if ( -e '/etc/redhat-release' || -e '/etc/SuSe-release' ) 
	{
		$command = '/bin/ping -c 3 -s 56 ' . $self->attr->mgtaddress;
		 
	} 
	
	return $self->_command($command);
}

sub _command {
	my($self, $command) = @_;
	my($result);
	
	if ( defined($command) ) {
		$command .= " 1>/dev/null 2>&1";
		Logger->debug("$command");
		$result = system($command);
		$result = $result ? 0 : 1;
	}
	
	return $result;
}

1;