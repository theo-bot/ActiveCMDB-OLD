package ActiveCMDB::Controller::Device;

=begin nd

    Script: ActiveCMDB::Controller::Device.pm
    ___________________________________________________________________________

    Version 1.0

    Copyright (C) 2012-2013 Theo Bot

    http://www.activecmdb.org


    Topic: Purpose

    ActiveCMDB::Controller::Device object

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
# Include required modules 
#
use Moose;
use namespace::autoclean;
use DateTime;
use Data::Dumper;
use POSIX;
use ActiveCMDB::Common::Conversion;
use ActiveCMDB::Common::Device;
use ActiveCMDB::Common::Location;
use ActiveCMDB::Common::Constants;
use ActiveCMDB::Object::Device;
use ActiveCMDB::Object::IpType;
use ActiveCMDB::Object::Vendor;
use ActiveCMDB::Object::ifEntry;
use ActiveCMDB::Object::entPhysicalEntry;
use ActiveCMDB::Object::Location;

BEGIN { extends 'Catalyst::Controller' }

my $config = ActiveCMDB::ConfigFactory->instance();
$config->load('cmdb');

sub index :Private {
	my($self, $c) = @_;
	my ($state);
	
	my @status = cmdb_list_byname('devStatus');
	
	$state = '';
	foreach my $s (@status) {
		$state .= sprintf("<option value='%d'>%s</option>", $s->{key}, $s->{value});
	}
	
	
	$c->stash->{statusOptions} = $state;
	$c->stash->{template} = 'device/device_container.tt';
}

sub find_by_name :Local {
	my($self, $c) = @_;
	my($rs,$searchStr, $maxRows, $row);
	
	
	$searchStr = $c->request->params->{name_startsWith};
	$maxRows   = $c->request->params->{maxRows};
	
	$rs = $c->model("CMDBv1::IpDevice")->search(
					{
						hostname => { 'like' => $searchStr . '%' }
					},
					{
						rows => $maxRows
					}
	);
	
	my @json = ();
	while ( $row = $rs->next )
	{
		push(@json, { id => $row->hostname, label => $row->hostname} );
	}
	
	$c->stash->{json} = { names => \@json };
	$c->forward( $c->view('JSON') );
}

sub discover_device :Local {
	my($self, $c) = @_;
	my($hostname,$device_id, $response);
	
	$hostname = $c->request->params->{hostname};
	
	$device_id = $self->get_id_by_name($c, $hostname);
	
	
	
	if ( defined($device_id) )
	{
		my $p = { device => { device_id => $device_id } };
		my $broker = ActiveCMDB::Common::Broker->new( $config->section('cmdb::broker') );
		$broker->init({ process => 'web'.$$ , subscribe => false });
		my $message = ActiveCMDB::Object::Message->new();
		$message->from('web'.$$ );
		$message->subject('DiscoverDevice');
		$message->to($config->section("cmdb::process::object::exchange"));
		$message->payload($p);
		$c->log->debug("Sending message to " . $message->to );
		$broker->sendframe($message,{ priority => PRIO_HIGH } );
	}
	
	$c->response->body( $response );
	$c->response->status(200);
}

sub fetchconfig_device :Local {
	my($self, $c) = @_;
	my($hostname,$device_id, $response);
	
	$hostname = $c->request->params->{hostname};
	
	$device_id = $self->get_id_by_name($c, $hostname);
	
	
	
	if ( defined($device_id) )
	{
		my $p = { device => { device_id => $device_id } };
		my $broker = ActiveCMDB::Common::Broker->new( $config->section('cmdb::broker') );
		$broker->init({ process => 'web'.$$ , subscribe => false });
		my $message = ActiveCMDB::Object::Message->new();
		$message->from('web'.$$ );
		$message->subject('FetchConfig');
		$message->to($config->section("cmdb::process::object::exchange"));
		$message->payload($p);
		$c->log->debug("Sending message to " . $message->to );
		$broker->sendframe($message,{ priority => PRIO_HIGH } );
	}
	
	$c->response->body( $response );
	$c->response->status(200);
}

sub fetch_device :Local {
	my($self, $c) = @_;
	my($hostname, $device_id,$device, $json, $type,$vendor);
	
	$hostname = $c->request->params->{hostname};
	$json = undef;
	
	$device_id = $self->get_id_by_name($c, $hostname);
	
	if ( defined($device_id) ) {
		$device = ActiveCMDB::Object::Device->new(device_id =>$device_id);
		$device->find();
		foreach my $attr (qw/device_id mgtaddress device_id/) 
		{
			$json->{$attr} = $device->$attr();
		}
		
		$type = ActiveCMDB::Object::IpType->new(sysobjectid => $device->sysobjectid);
		$type->find();
		$json->{descr} = $type->descr;
		
		$vendor = ActiveCMDB::Object::Vendor->new({ id => $type->vendor_id});
		$vendor->find();
		$json->{vendor} = $vendor->name;
		my $dt = DateTime->from_epoch( epoch => $device->disco);
		$json->{disco} = $dt->ymd . ' ' . $dt->hms;
		$json->{added} = sprintf("%s",$device->added);
		$json->{added} =~ s/T/ /;
		$json->{descr_tr} = '';
		if ( length( $device->sysdescr() ) > 60 )
		{
			$c->log->debug("Truncating description");
			$json->{descr_tr} = substr($device->sysdescr(),0,57) . '...';
		} else {
			$json->{descr_tr} = $type->sysdescr();
		}
		$json->{sysdescr} = $device->sysdescr();
 		$json->{descr_tr} =~ s/\r//g;
 		$json->{descr_tr} =~ s/\n//g;
 		$json->{critical} = $device->is_critical;
	}
	
	$c->stash->{json} = $json;
	$c->forward( $c->view('JSON') );
}

sub interface :Local {
	my($self,$c) = @_;
	my($rs,$id,$ref);
	my @int = ();
	
	$ref = ref $c->request->params->{id};
	
	if ( $ref eq 'ARRAY' )
	{
		$id = $c->request->params->{id}[0];
	} else {
		$id = $c->request->params->{id};
	}
	
	if ( $id > 0 )
	{
		$c->log->info("Fetching interfaces for $id");
		$rs = $c->model("CMDBv1::IpDeviceInt")->search(
						{
							device_id => $id
						},
						{
							order_by => 'ifindex'														
						}
					);
		while (my $row = $rs->next )
		{
			my $int = undef;
			$int->{ifindex} = $row->ifindex;
			$int->{ifdescr} = $row->ifdescr;
			$int->{admin}	= $row->ifadminstatus == 1 ? 'Up' : 'Down';
			$int->{oper}	= $row->ifoperstatus == 1 ? 'Up' : 'Down';
			
			push(@int, $int);
		}
	}
	
	$c->stash->{device_id} = $id;
	$c->stash->{int} = [ @int ];
	$c->stash->{template} = 'device/device_interfaces.tt';
	
}

sub fetch_interface :Local {
	my($self, $c) = @_;
	my($device_id,$ifindex,$json, $int);
	
	$device_id = $c->request->params->{device_id};
	$ifindex   = $c->request->params->{ifindex};
	
	$c->log->debug("Fetcing data for $device_id :: $ifindex");
	$int = ActiveCMDB::Object::ifEntry->new({device_id => $device_id, ifindex => $ifindex });
	$int->get_data();
	$json = undef;
	for my $attr (qw/ifindex ifdescr ifname ifalias ifphysaddress /)
	{
		$json->{$attr} = $int->$attr();
	}
	if ( $int->iftype > 0 ) {
		$json->{iftype} = sprintf("%s(%d)",cmdb_convert('ifType', $int->iftype()), $int->iftype() );
	} else {
		$json->{iftype} = "";
	}
	$json->{ifspeed} = $int->ifspeedstr();
	$c->stash->{json} = $json;
	$c->forward( $c->view('JSON') );
}


sub structure :Local {
	my($self, $c) = @_;
	my($rs, $id,$ref,$tree);
	my @entries = ();
	
	my %icons = ( '3' => '/static/images/dtree/base.gif',
				 '10' => '/static/images/dtree/ethernet.jpg'
	);
	
	$ref = ref $c->request->params->{id};
	
	if ( $ref eq 'ARRAY' )
	{
		$id = $c->request->params->{id}[0];
	} else {
		$id = $c->request->params->{id};
	}
	
	if ( $id > 0 )
	{
		$rs = $c->model("CMDBv1::IpDeviceEntity")->search(
					{
						device_id => $id
					},
					{
						order_by => 'entphysicalindex',
						columns  => qw/entphysicalindex/
					}
		);
		$tree = undef;
		
		while ( my $row = $rs->next )
		{
			my $ent = ActiveCMDB::Object::entPhysicalEntry->new(device_id => $id, entphysicalindex => $row->entphysicalindex);
			$ent->get_data();
			$ent->icon($icons{ $ent->entphysicalclass });
			if ( $ent->entphysicalcontainedin == 0 ) { $ent->entphysicalcontainedin(-1); }
			push(@entries, $ent); 
		}
	}
	
	$c->stash->{device_id} = $id;
	$c->stash->{tree} = [ @entries ];
	$c->stash->{template} = 'device/device_structure.tt';
}

sub fetch_entity :Local {
	my($self, $c) = @_;
	
	my($device_id,$index,$json, $ent, $int);
	
	$device_id = $c->request->params->{device_id};
	$index   = $c->request->params->{index};
	
	$c->log->debug("Fetcing data for $device_id :: $index");
	$ent = ActiveCMDB::Object::entPhysicalEntry->new({device_id => $device_id, entphysicalindex => $index });
	$ent->get_data();
	$json = undef;
	for my $attr (qw/entphysicalname entphysicaldescr entphysicalclass entphysicalhardwarerev entphysicalfirmwarerev entphysicalsoftwarerev entphysicalserialnum /)
	{
		$json->{$attr} = $ent->$attr();
	}
	if ( defined($json->{entphysicalclass}) && $json->{entphysicalclass} > 0 )
	{
		$json->{entphysicalclass} = cmdb_convert('entPhysicalClass', $json->{entphysicalclass}) . ' (' . $json->{entphysicalclass} . ')';
	}
	if ( defined($ent->ifindex()) )
	{
		$int = ActiveCMDB::Object::ifEntry->new({device_id => $device_id, ifindex => $ent->ifindex });
		$int->get_data();
		$json->{logicalUnit} = $int->ifdescr() || $int->ifname();
	} else {
		$json->{logicalUnit} = '';
	}
	
	
	$c->stash->{json} = $json;
	$c->forward( $c->view('JSON') );
}

sub connections :Local {
	my($self, $c) = @_;
	my($rs, $id, $ref,$row, $device);
	
	my @conns = ();
	
	$ref = ref $c->request->params->{id};
	
	if ( $ref eq 'ARRAY' )
	{
		$id = $c->request->params->{id}[0];
	} else {
		$id = $c->request->params->{id};
	}
	$device = ActiveCMDB::Object::Device->new(device_id => $id);
	$device->find();
	
	$rs = $c->model('CMDBv1::IpDeviceAt')->search(
					{
						"me.device_id" => $id 
					},
					{
						join		=> 'interface',
						'+select'	=> ['interface.ifname'],
						'+as'		=> ['ifname']
					}
	);
	
	while ( $row = $rs->next ) 
	{ 
		my $nbr_name = '';
		if ( $row->atnetaddress ne $device->hostname )
		{
			$nbr_name = cmdb_get_host_by_ip($row->atnetaddress);
		}
		push(@conns, { mac => $row->atphysaddress, net => $row->atnetaddress, ifname => $row->get_column('ifname'), method => 'arp' });
	}
	
	$c->stash->{conns} = [ @conns ];
	$c->stash->{template} = 'device/device_nbr.tt'
}

sub site :Local {
	my($self, $c) = @_;
	my($ref,$id,$device,$site);
	
	$ref = ref $c->request->params->{id};
	
	if ( $ref eq 'ARRAY' )
	{
		$id = $c->request->params->{id}[0];
	} else {
		$id = $c->request->params->{id};
	}
	
	if ( $id > 0 )
	{
		$device = ActiveCMDB::Object::Device->new(device_id => $id);
		$device->find();
		$c->stash->{device} = $device;
		
		$site = ActiveCMDB::Object::Location->new(location_id => $device->location_id );
		$site->get_data();
		$c->stash->{site} = $site;
		$c->stash->{parentStr} = $site->site_parent();
	}
	$c->stash->{sites} = [ cmdb_get_sites() ];
	
	$c->stash->{device_id} = $id;
	$c->stash->{template} = 'device/device_site.tt';
}

sub set_location :Local {
	my($self,$c) = @_;
	
	# Init variables
	my($location_id, $device_id, $device, $response);
	
	# Get parameters
	$location_id = $c->request->params->{site_id} || 0;
	$device_id   = $c->request->params->{device_id} || 0;
	
	if ( $location_id > 0 && $device_id > 0 )
	{
		$device = ActiveCMDB::Object::Device->new(device_id => $device_id);
		$device->find();
		
		# Set the new location
		$device->location_id($location_id);
		
		# Save the data
		$device->save();
		$device->journal({ prio => 5, user => $c->request->params->{username}, text => "Location updated to $location_id", date => DateTime->now()  });
		$response = "Site data saved";
		$c->log->info("Device site data updated");
	} else {
		$response = "Invalid input";
		$c->log->warn("Device site data failed to update");
	}
	
	$c->response->body( $response );
	$c->response->status(200);
}

sub maintenance :Local {
	my($self, $c) = @_;
	my($id,$ref,$rs, $device);
	my %maint = ();
	my $size = 0;
	
	$ref = ref $c->request->params->{id};
	
	if ( $ref eq 'ARRAY' )
	{
		$id = $c->request->params->{id}[0];
	} else {
		$id = $c->request->params->{id};
	}
	
	$rs = $c->model("CMDBv1::Maintenance")->search();
	while ( my $row = $rs->next )
	{
		$maint{ $row->maint_id }->{device} = 0;
		$maint{ $row->maint_id }->{descr}  = $row->descr;
		$maint{ $row->maint_id }->{id}     = $row->maint_id;
		$size++;
	}
	
	if ( $id > 0 )
	{
		$device = ActiveCMDB::Object::Device->new(device_id => $id );
		$device->find();
		foreach my $s ( $device->get_maint() )
		{
			$maint{ $s } = 1;
		}
	}
	
	$c->stash->{maint} = \%maint;
	$c->stash->{size}  = $size;
	$c->stash->{device_id} = $id;
	
	$c->stash->{template} = "device/maintenance.tt";
}

sub setmaint :Local {
	my($self, $c) = @_;
	my($ref,$maint,$response,$id);
	
	$ref = ref $c->request->params->{id};
	
	
	if ( $ref eq 'ARRAY' )
	{
		$id = $c->request->params->{id}[0];
	} else {
		$id = $c->request->params->{id};
	}
	if ( $id > 0 )
	{
		my $device = ActiveCMDB::Object::Device->new(device_id => $id );
		$device->find();
		$device->set_maint( $c->request->params->{maint} );
	}
	
	$c->response->body( $response );
	$c->response->status(200);
}

sub security :Local {
	my($self, $c) = @_;
	
	$c->log->debug( "Get parameters \n" . $c->request->query_parameters->{id}->[0] );
	if ( $c->request->query_parameters->{id}->[0] > 0 )
	{
		my $device = ActiveCMDB::Object::Device->new(device_id => $c->request->query_parameters->{id}->[0] );
		$device->find();
		$c->stash->{device} = $device;
	}
	
	$c->stash->{template} = 'device/device_security.tt';
}

sub update_security :Local {
	my($self, $c) = @_;
	my($device);
	$c->log->info("Updating security parameters");
	
	if ( $c->request->params->{device_id} > 0 )
	{
		$device = ActiveCMDB::Object::Device->new(device_id => $c->request->params->{device_id} );
		$device->find();
		
		foreach my $attr (keys %{$c->request->params})
		{
			next if ( $attr =~ /device_id/ );
			$device->$attr( $c->request->params->{$attr} );
		}
		if ( $device->save() )
		{
			$device->journal({ prio => 6, user => $c->request->params->{username}, text => "Security parameters updated", date => DateTime->now() });
			$c->response->body("Updated device parameters");
			$c->response->status(200);
		} else {
			$c->response->body("Failed to update device parameters");
			$c->response->status(200);
		}
	}
}

sub journal :Local {
	my($self, $c) = @_;
	my($device, $id);
	
	$id = $c->request->query_parameters->{id}->[0] || $c->request->params->{device_id};
	
	if (  $id > 0 )
	{
		$device = ActiveCMDB::Object::Device->new(device_id => $id );
	}
	
	$c->stash->{device_id} = $id;
	$c->stash->{template} = "device/device_journal.tt";
}

sub get_id_by_name {
	my($self, $c, $hostname) = @_;
	my($row);
	
	
	$row = $c->model("CMDBv1::IpDevice")->find(
			{
				hostname => $hostname
			},
			{
				columns => qw/device_id/
			}
	);
	if ( defined($row) ) {
		return $row->device_id;
	}
}


sub devconfig :Local {
	my($self, $c) = @_;
	my($id,$ref);
	
	$ref = ref $c->request->params->{id};
	
	
	if ( $ref eq 'ARRAY' )
	{
		$id = $c->request->params->{id}[0];
	} else {
		$id = $c->request->params->{id};
	}
	
	if ( $id > 0 )
	{
		my $device = ActiveCMDB::Object::Device->new(device_id => $id );
		$device->find();
		$c->stash->{device}  = $device;
		$c->stash->{cfgdata} = [ $device->configs() ];
		
	} 
	
	$c->stash->{template} = 'device/device_configdata.tt';
}

1;