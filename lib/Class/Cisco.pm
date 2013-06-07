package Class::Cisco;

=begin nd

    Script: Class::Cisco.pm
    ___________________________________________________________________________

    Version 1.0

    Copyright (C) 2012-2013 Theo Bot

    http://www.activecmdb.org


    Topic: Purpose

    Wrapper class for cisco devices

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
	
	This a wrapper class for common cisco operations
	
	
=cut

use Methods;
use Moose;

extends 'Class::Device';

# 
# Discovery mixins
#
with 'Class::Cisco::vmVlan';

#
# Configuration mixins
#
with 'Class::Cisco::CopyConfig';
with 'Class::Cisco::NetConfig';

1;