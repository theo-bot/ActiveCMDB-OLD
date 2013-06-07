package Class::Device::Entity;

=begin nd

    Script: CMDB::Device::Entity.pm
    ___________________________________________________________________________

    Version 1.0

    Copyright (C) 2012-2013 Theo Bot

    http://www.activecmdb.org


    Topic: Purpose

    Class::Device::Entity class definition

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
use Data::Dumper;
use Try::Tiny;
use Logger;
use ActiveCMDB::Common::Constants;
use ActiveCMDB::Object::entPhysicalEntry;

my %entTable = (
					'entPhysicalIndex'			=> 'entphysicalindex',
					'entPhysicalDescr'			=> 'entphysicaldescr',
					'entPhysicalVendorType'		=> 'entphysicalvendortype',
					'entPhysicalContainedIn'	=> 'entphysicalcontainedin',
					'entPhysicalClass'			=> 'entphysicalclass',
					'entPhysicalName'			=> 'entphysicalname',
					'entPhysicalHardwareRev'	=> 'entphysicalhardwarerev',
					'entPhysicalFirmwareRev'	=> 'entphysicalfirmwarerev',
					'entPhysicalSoftwareRev'	=> 'entphysicalsoftwarerev',
					'entPhysicalSerialNum'		=> 'entphysicalserialnum',
					'entAliasLogicalIndexOrZero' => 'ifindex',
					'entAliasMappingIdentifier'	 => 'ifindex',
				);
				
sub discover_entity
{
	my($self, $data) = @_;
	my($oid, $res, $res1, $index, $value);
	my %oids = ();
	my $entity = undef;
	
	Logger->info("Starting discovery Entity MIB for " . $self->attr->hostname);
	
	
	#
	# Cache all snmp object id's
	#
	foreach my $key ( keys %entTable )
	{
		$oids{$key} = $self->get_oid_by_name($key);
	}
	
	
	#$oid = $self->get_oid_by_name('');
	$res = $self->snmp_table($oids{'entPhysicalVendorType'});
	
	if ( defined($res) )
	{
		foreach $oid (keys %$res)
		{
			$oid =~ /^.*\.(\d+)$/;
			$index = $1;
		
			$entity->{$index} = ActiveCMDB::Object::entPhysicalEntry->new(
					{
						device_id 			=> $self->device_id, 
						entphysicalindex	=> $index
					}
				);
			$entity->{$index}->get_data();
			
			#
			# Store new discovery timestamp
			#
			$entity->{$index}->disco($data->{system}->disco);
			
			
			my %request = ();
			my @oids    = ();
			$entity->{$index}->{ $entTable{'entPhysicalVendorType'} } = $res->{$oid};
			foreach my $object ( keys %entTable ) {
				next if ( $object =~ /entPhysicalVendorType|entPhysicalIndex|entAliasLogicalIndexOrZero|entAliasMappingIdentifier|ifIndex/ );
				my $snmpoid = $oids{$object} . '.' . $index;
				push(@oids, $snmpoid);
				$request{$object} = $snmpoid;
			}
			$res1 = $self->snmp_nget(@oids);
			if ( defined($res1) )
			{
				foreach my $object (keys %request)
				{
					my $method = $entTable{$object};
					$entity->{$index}->$method($res1->{$request{$object}});
				}
			} else {
				Logger->warn("Failed to get entity data for index $index: ".$self->comms->error);
			}
			
		}
	} else {
		Logger->warn("Failed to read entPhysicalVendorType table: ".$self->comms->error)
	}
	
	# Get entity to ifIndex mapping
	Logger->info("Get entity to ifIndex mapping");
	$res = $self->snmp_table($oids{'entAliasLogicalIndexOrZero'});
	if ( defined($res) )
	{
		foreach $oid (keys %$res)
		{
			$oid =~ /^.*\.(\d+)\.\d+$/;
			$index = $1;
			Logger->info("Processing oid $oid :: $index");
			$value = $res->{$oid};
			$value =~ /^.*\.(\d+)$/;
			$entity->{$index}->ifindex($1);
		}
	} else {
		Logger->warn("Failed to get entity to ifIndex mapping: ".$self->comms->error);
		
		Logger->debug("Let's try the entAliasMappingIdentifier table");
		$res = $self->snmp_table($oids{'entAliasMappingIdentifier'});
		if ( defined($res) )
		{
			foreach $oid (keys %$res)
			{
				$oid =~ /^.*\.(\d+)\.\d+$/;
				$index = $1;
				Logger->info("Processing oid $oid :: $index");
				$value = $res->{$oid};
				$value =~ /^.*\.(\d+)$/;
				$entity->{$index}->ifindex($1);	
			}
		} else {
			Logger->warn("Unable to connect entities to ifIndex tables");
		}
	}
	
	return $entity;
}

sub save_entity
{
	my($self, $data) = @_;
	my($transaction, $rs);
	
	$transaction = sub {
		foreach my $index ( keys %$data )
		{
			$data->{$index}->save();
			
		}
		
		#
		# Now delete objects that weren't detected
		#
		$rs = $self->attr->schema->resultset("IpDeviceEntity")->search(
			{
				device_id	=> $self->device_id,
				disco		=> { '!=', $self->attr->disco },
			}
		);
		while ( my $object = $rs->next )
		{
			$object->delete;
		}
		
		return true;		
	};
	
	try {
		$self->attr->schema->txn_do($transaction);
	} catch {
		Logger->error("Transaction failed: " . $_);
	};
}

1;