package Class::Cisco::OsVersion;

=begin nd

    Script: Class::Cisco::OsVersion.pm
    ___________________________________________________________________________

    Version 1.0

    Copyright (C) 2011-2015 Theo Bot

    http://www.activecmdb.org


    Topic: Purpose

    OS Version Helper class for cisco devices

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
	
	This a helper to discover the os version on cisco operations
	
	
=cut

use v5.16.0;
use Moose::Role;

sub discover_osversion
{
	my ($self, $data) = @_;
	
	my $sysdesc = $self->attr->sysdescr;
	if ( $sysdesc =~ /IOS/ )
	{
		$self->attr->os_type('IOS');
		if ( $sysdesc =~ /Version (.+?),/ ) {
			$self->attr->os_version($1);
		}
	} 
};
	
sub save_osversion
{
	my($self) = @_;
	$self->attr->save();
};

1;