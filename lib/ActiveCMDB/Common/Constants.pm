package ActiveCMDB::Common::Constants;

=begin nd

    Script: ActiveCMDB::Common::Constants.pm
    ___________________________________________________________________________

    Version 1.0

    Copyright (C) 2012-2013 Theo Bot

    http://www.activecmdb.org


    Topic: Purpose

    ActiveCMDB::Common::Constants class definition

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
	
	Hold all constant definitions
	
	
=cut

use Exporter;
use vars qw($cfg_state, $objects_mapper);

@ISA = ('Exporter');
@EXPORT = qw( 
				PROC_SHUTDOWN PROC_RUNNING PROC_DISABLED PROC_IDLE PROC_BUSY
				MSG_TYPE_JSON	SNMP_LARGE_IFTABLE
				OID_SYSOBJECTID
				true false TRUE FALSE TCP_TIMEOUT
				PRIO_HIGH PRIO_LOW PRIO_NORMAL
				$m_repeat $cfg_state $objects_mapper
			);


			
#
# Process states
#
use constant PROC_SHUTDOWN	=> 1;	# Process is stopped
use constant PROC_RUNNING	=> 2;	# Process is running
use constant PROC_DISABLED	=> 3;	# Process is disabled
use constant PROC_IDLE		=> 4;	# Process is idle
use constant PROC_BUSY		=> 5;	# Process is busy

#
# Message constants
#
use constant MSG_TYPE_JSON => 'application/json';

#
# Other
#
use constant true  => 1;
use constant TRUE  => 1;
use constant false => 0;
use constant FALSE => 0;
use constant TCP_TIMEOUT => 5;

#
# SNMP Basic OIDS
#
use constant OID_SYSOBJECTID => '1.3.6.1.2.1.1.2.0';

use constant SNMP_LARGE_IFTABLE	=> 1000;

#
# Messaging
#
use constant	PRIO_HIGH	=> 7;
use constant	PRIO_LOW	=> 0;
use constant	PRIO_NORMAL	=> 4;

# 
# Config states
#
$cfg_state = {
				0	=> 'Available',
				1	=> 'Broken',
				2	=> 'Locked'
};

#
# Object types
# 
$objects_mapper = {
				'device'	=> 'ActiveCMDB::Object::Device',
				'vendor'	=> 'ActiveCMDB::Object::Vendor',
				'message'	=> 'ActiveCMDB::Object::Message'
}