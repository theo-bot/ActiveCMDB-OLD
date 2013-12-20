package ActiveCMDB::Controller::Device;
=head1 MODULE - ActiveCMDB::Controller::Device
    ___________________________________________________________________________

=head1 VERSION

    Version 1.0

=head1 COPYRIGHT

    Copyright (C) 2011-2015 Theo Bot

    http://www.activecmdb.org


=head1 DESCRIPTION

    Catalyst ActiveCMDB Device Cotroller

=head1 LICENSE

    This program is free software; you can redistribute it and/or
    modify it under the terms of the GNU General Public License
    as published by the Free Software Foundation; either version 2
    of the License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

=cut

=head1 IMPORTS

 use Moose;
 use namespace::autoclean;
 use DateTime;
 use Data::Dumper;
 use POSIX;
 use ActiveCMDB::Common::Conversion;
 use ActiveCMDB::Common::Device;
 use ActiveCMDB::Common::Location;
 use ActiveCMDB::Common::Constants;
 use ActiveCMDB::Common::Vendor;
 use ActiveCMDB::Object::Device;
 use ActiveCMDB::Object::IpType;
 use ActiveCMDB::Object::Vendor;
 use ActiveCMDB::Object::ifEntry;
 use ActiveCMDB::Object::entPhysicalEntry;
 use ActiveCMDB::Object::Location;
 use ActiveCMDB::Object::Contract;
 
=cut
#
# Include required modules 
#
use Moose;
use namespace::autoclean;
use DateTime;
use Data::Dumper;
use POSIX;
use Switch;
use ActiveCMDB::Common::Security;
use ActiveCMDB::Common::Conversion;
use ActiveCMDB::Common::Device;
use ActiveCMDB::Common::Location;
use ActiveCMDB::Common::Constants;
use ActiveCMDB::Common::Vendor;
use ActiveCMDB::Common::IpDomain;
use ActiveCMDB::Object::Device;
use ActiveCMDB::Object::IpType;
use ActiveCMDB::Object::Vendor;
use ActiveCMDB::Object::ifEntry;
use ActiveCMDB::Object::entPhysicalEntry;
use ActiveCMDB::Object::Location;
use ActiveCMDB::Object::Contract;
use ActiveCMDB::Object::Circuit::VLan;
use ActiveCMDB::Object::Circuit::MplsVpn;
use ActiveCMDB::Object::Circuit::FrDlci;

BEGIN { extends 'Catalyst::Controller' }

my $config = ActiveCMDB::ConfigFactory->instance();
$config->load('cmdb');

sub index :Private {
	my($self, $c) = @_;
	my ($state);
	if ( cmdb_check_role($c,qw/deviceViewer deviceAdmin/) )
	{
		my @status = cmdb_list_byname('devStatus');
	
		$state = '';
		foreach my $s (@status) {
			$state .= sprintf("<option value='%d'>%s</option>", $s->{key}, $s->{value});
		}
	
		my @domains = cmdb_get_domains();
		$c->stash->{ipdomains} = [ @domains ];
	
		$c->stash->{statusOptions} = $state;
		$c->stash->{template} = 'device/device_container.tt';
	} else {
		$c->response->redirect($c->uri_for($c->controller('Root')->action_for('noauth')));
	}
}

sub find_by_name :Local {
	my($self, $c) = @_;
	my($rs,$searchStr, $maxRows, $row);
	
	if ( cmdb_check_role($c,qw/deviceViewer deviceAdmin/) )
	{
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
	} else {
		$c->response->redirect($c->uri_for($c->controller('Root')->action_for('noauth')));
	}
}

sub discover_device :Local {
	my($self, $c) = @_;
	
	if ( cmdb_check_role($c,qw/deviceViewer deviceAdmin/) )
	{
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
	} else {
		$c->response->body('Unauthorized');
		$c->response->status(401);
	}
}

sub fetchconfig_device :Local {
	my($self, $c) = @_;
	
	if ( cmdb_check_role($c,qw/fetchConfig deviceAdmin/) )
	{
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
	} else {
		$c->response->body('Unauthorized');
		$c->response->status(401);
	}
}

sub fetch_device :Local {
	my($self, $c) = @_;
	my($hostname, $device_id,$device, $json, $type,$vendor);
	
	if ( cmdb_check_role($c,qw/deviceViewer deviceAdmin/) )
	{
		$hostname = $c->request->params->{hostname};
		$json = undef;
	
		$device_id = $self->get_id_by_name($c, $hostname);
	
		if ( defined($device_id) ) {
			$device = ActiveCMDB::Object::Device->new(device_id =>$device_id);
			$device->find();
			foreach my $attr (qw/device_id mgtaddress device_id status/) 
			{
				$json->{$attr} = $device->$attr();
			}
		
			#
			# If the sysobjectid is set, fetch those details
			#
			if ( defined($device->sysobjectid) ) {
				$c->log->debug("Device sysobject id set to " . $device->sysobjectid );
				$type = ActiveCMDB::Object::IpType->new(sysobjectid => $device->sysobjectid);
				$type->find();
				$json->{descr} = $type->descr;
				$vendor = ActiveCMDB::Object::Vendor->new({ id => $type->vendor_id});
				$vendor->find();
				$json->{vendor} = $vendor->name;
			} else {
				$c->log->debug("Device sysobjectid not set");
				$json->{vendor} = '';
				$json->{descr} = '';
			}
		
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
				if ( defined($type) ) 
				{
					$c->log->debug("Setting descr_tr to " . $type->descr);
					$json->{descr_tr} = $type->descr(); 
				} else {
					$c->log->warn("ERROR: Type object not defined");
					$json->{descr_tr} = '';
				}
			}
			$json->{sysdescr} = $device->sysdescr();
 			$json->{descr_tr} =~ s/\r//g;
 			$json->{descr_tr} =~ s/\n//g;
 			$json->{critical} = $device->is_critical;
 			$json->{ipdomain} = $device->domain_id;
 			if ( defined($device->os_type) )
 			{
 				$json->{os} = $device->os_type;
 				if ( defined($device->os_version) && $device->os_version ) 
 				{
 					$json->{os} .= ' (' . $device->os_version . ')';
 				}
 			} else {
 				$json->{os} = '';
 			}
		}
		#$c->log->debug(Dumper($json));
		$c->stash->{json} = $json;
		$c->forward( $c->view('JSON') );
	} else {
		$c->response->redirect($c->uri_for($c->controller('Root')->action_for('noauth')));
	}
}

sub save_device :Local {
	my($self, $c) = @_;
	
	if ( cmdb_check_role($c,qw/deviceAdmin/) )
	{
		my($device, $device_id);
	
		$device_id = int($c->request->params->{device_id});
	
		if ( $device_id > 0 )
		{
			$device = ActiveCMDB::Object::Device->new(device_id => $device_id );
			$device->get_data();
		} else {
			$device = ActiveCMDB::Object::Device->new();
		}
	
		foreach my $param (qw/hostname mgtaddress domain_id/)
		{
			if ( defined($c->request->params->{$param}) && $c->request->params->{$param} )
			{
				$device->$param($c->request->params->{$param});
			} 
		}
		$device->status( $c->request->params->{status} );
	
		if ( defined($c->request->params->{isCritical}) && $c->request->params->{isCritical} == 1 )
		{
			$device->is_critical(1);
		} else {
			$device->is_critical(0);
		}
	
		if ( defined($device->mgtaddress) ) {
			$device->save();
		}
	} 
}

sub interface :Local {
	my($self,$c) = @_;
	
	if ( cmdb_check_role($c,qw/deviceViewer deviceAdmin/) )
	{
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
	} else {
		$c->log->warn("Unauthorized");
	}
}

sub fetch_interface :Local {
	my($self, $c) = @_;
	
	if ( cmdb_check_role($c,qw/deviceViewer deviceAdmin/) )
	{
	
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
	
		my $item = 0;
		$json->{networks} = '';
		foreach my $net (get_networks_by_interface($device_id, $ifindex))
		{
			if ( $item > 0 ) { $json->{networks} .= "\n"; }
			$json->{networks} .= $net->ipadentaddr . '/' . $net->ipadentprefix;
			$item++;
		}
	
		$c->stash->{json} = $json;
		$c->forward( $c->view('JSON') );
	} else {
		$c->log->warn("Unauthorized");
	}
}


sub structure :Local {
	my($self, $c) = @_;
	
	if ( cmdb_check_role($c,qw/deviceViewer deviceAdmin/) )
	{
	
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
	} else {
		$c->log->warn("Unauthorized");
	}
}

sub fetch_entity :Local {
	my($self, $c) = @_;
	
	if ( cmdb_check_role($c,qw/deviceViewer deviceAdmin/) )
	{
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
	} else {
		$c->log->warn("Unauthorized");
	}
}

sub connections :Local {
	my($self, $c) = @_;
	
	if ( cmdb_check_role($c,qw/deviceViewer deviceAdmin/) )
	{
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
							'+as'		=> ['ifname'],
							order_by	=> 'ifIndex'
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
	} else {
		$c->log->warn("Unauthorized");
	}
}

sub site :Local {
	my($self, $c) = @_;
	
	if ( cmdb_check_role($c,qw/deviceViewer deviceAdmin/) && cmdb_check_role($c,qw/siteViewer siteAdmin/))
	{
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
	} else {
		$c->log->warn("Unauthorized");
	}
}

sub set_location :Local {
	my($self,$c) = @_;
	
	if ( cmdb_check_role($c,qw/deviceAdmin/) )
	{
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
	} else {
		$c->response->body("Unauthorized");
		$c->response->status(401);
	}
}

sub maintenance :Local {
	my($self, $c) = @_;
	
	if ( cmdb_check_role($c,qw/deviceViewer deviceAdmin/) )
	{
	
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
	} else {
		$c->log-warn("Unauthorized");
	}
}

sub setmaint :Local {
	my($self, $c) = @_;
	
	if ( cmdb_check_role($c,qw/deviceAdmin/) )
	{
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
	} else {
		$c->response->body("Unauthorized");
		$c->response->status(401);
	}
}

sub security :Local {
	my($self, $c) = @_;
	
	if ( cmdb_check_role($c,qw/deviceViewer deviceAdmin/) )
	{
		$c->log->debug( "Get parameters \n" . $c->request->query_parameters->{id}->[0] );
		if ( $c->request->query_parameters->{id}->[0] > 0 )
		{
			my $device = ActiveCMDB::Object::Device->new(device_id => $c->request->query_parameters->{id}->[0] );
			$device->find();
			$c->stash->{device} = $device;
		}
	
		$c->stash->{template} = 'device/device_security.tt';
	} else {
		$c->log->warn("Unauthorized");
	}
}

sub update_security :Local {
	my($self, $c) = @_;
	if ( cmdb_check_role($c,qw/deviceAdmin/) )
	{
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
	} else {
		$c->response->body("Unauthorized");
		$c->response->status(401);
	}
}

sub journal :Local {
	my($self, $c) = @_;
	
	if ( cmdb_check_role($c,qw/deviceViewer deviceAdmin/) )
	{
		my($device, $id);
	
		$id = $c->request->query_parameters->{id}->[0] || $c->request->params->{device_id};
	
		if (  $id > 0 )
		{
			$device = ActiveCMDB::Object::Device->new(device_id => $id );
		}
	
		$c->stash->{device_id} = $id;
		$c->stash->{template} = "device/device_journal.tt";
	} else {
		$c->log->warn("Unauthorized");
	}
}

sub get_id_by_name {
	my($self, $c, $hostname) = @_;
	
	if ( cmdb_check_role($c,qw/deviceViewer deviceAdmin admin/) )
	{
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
	} else {
		$c->log->warn("Unauthorized");
	}
}


sub devconfig :Local {
	my($self, $c) = @_;
	
	if ( cmdb_check_role($c,qw/deviceViewer deviceAdmin/) )
	{
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
	} else {
		$c->log->warn("Unauthorized");
	}
}

sub contract :Local {
	my($self, $c) = @_;
	if ( cmdb_check_role($c,qw/deviceViewer deviceAdmin/) &&  cmdb_check_role($c,qw/contractViewer contractAdmin/) )
	{
		my($ref, $id, $device, $contract, $vendor);
	
		$ref = ref $c->request->params->{id};
	
		if ( $ref eq 'ARRAY' )
		{
			$id = $c->request->params->{id}[0];
		} else {
			$id = $c->request->params->{id};
		}
	
		if ( $id > 0 )
		{
			$device = ActiveCMDB::Object::Device->new(device_id => $id );
			$device->get_data();
		
			$contract = ActiveCMDB::Object::Contract->new(id => $device->contract_id);
			$contract->get_data();
		
			$vendor = ActiveCMDB::Object::Vendor->new(id => $contract->vendor_id);
			$vendor->get_data();
		}
		my %vendors = cmdb_get_vendors();
	
		$c->log->debug("URL:" . $vendor->support_www);
	
		$c->stash->{vendors} = \%vendors;
		$c->stash->{device}   = $device;
		$c->stash->{contract} = $contract;
		$c->stash->{vendor}   = $vendor;
		$c->stash->{template} = 'device/device_contract.tt';
	} else {
		$c->log->warn("Unauthorized");
	}
} 

=head2 circuits

Display device circuits

=cut

sub circuits :Local {
	my($self, $c) = @_;
	if ( cmdb_check_role($c,qw/deviceViewer deviceAdmin/) )
	{
		my($ref,$device_id);
	
		$ref = ref $c->request->params->{id};
	
		if ( $ref eq 'ARRAY' )
		{
			$device_id = $c->request->params->{id}[0];
		} else {
			$device_id = $c->request->params->{id};
		}
	
		if ( $device_id > 0 ) 
		{
			$c->stash->{device_id} = $device_id;
			$c->stash->{vlans}  = get_vlans_by_device($device_id) ; 
			$c->stash->{vrfs}   = get_vrfs_by_device($device_id) ;
			$c->stash->{frdlci} = get_dlci_by_device($device_id);
		} else {
			$c->log->warn('Device_id not set');
		}
	
		$c->stash->{template} = 'device/device_circuits.tt';
	} else {
		$c->log->warn("Unauthorized");
	}
}

sub fetch_circuit :Local {
	my($self,$c) = @_;
	
	if ( cmdb_check_role($c,qw/deviceViewer deviceAdmin/) )
	{
		my($device_id,$index,$json, $circuit_id, $type,$circuit, $ifindex);
	
		$device_id  = $c->request->params->{device_id};
		$circuit_id = $c->request->params->{circuit};
		$ifindex    = $c->request->params->{ifindex};
		$type       = $c->request->params->{type};
		$json		= undef;
	
		#$c->log->debug("Fetcing data for $device_id :: $index");
		if ( $type == 0 )
		{
			$circuit = ActiveCMDB::Object::Circuit::VLan->new(device_id => $device_id, vlan_id => $circuit_id);
			$circuit->get_data();
		
			$json->{circuitName} = 'Vlan ' . $circuit_id;
			$json->{circuitDesc} = $circuit->name;
			$json->{circuitLow}  = 0;
			$json->{circuitHigh} = 0;
			my @interfaces = ();
		
			foreach my $int ($circuit->interfaces())
			{
				if ( $int->ifspeed < $json->{Low} || $json->{Low} == 0 )
				{
					$json->{Low} = $int->ifspeed;
					$json->{circuitLow} = $int->ifspeedstr();
				}
				if ( $int->ifspeed > $json->{High}) {
					$json->{High} = $int->ifspeed;
					$json->{circuitHigh} = $int->ifspeedstr();
				}
				push(@interfaces, $int->ifname() );
			}
			$json->{cicuitUnits} = join(',', @interfaces);
		}
		if ( $type == 1 )
		{
			$circuit = ActiveCMDB::Object::Circuit::MplsVpn->new(device_id => $device_id, rd => $circuit_id);
			$circuit->get_data();
		
			$json->{circuitName} = $circuit->rd;
			$json->{circuitDesc} = $circuit->name;
			$json->{circuitLow}  = 0;
			$json->{circuitHigh} = 0;
			my @interfaces = ();
		
			foreach my $int ($circuit->interfaces())
			{
				if ( $int->ifspeed < $json->{Low} || $json->{Low} == 0 )
				{
					$json->{Low} = $int->ifspeed;
					$json->{circuitLow} = $int->ifspeedstr();
				}
				if ( $int->ifspeed > $json->{High}) {
					$json->{High} = $int->ifspeed;
					$json->{circuitHigh} = $int->ifspeedstr();
				}
				push(@interfaces, $int->ifname() );
			}
			$json->{cicuitUnits} = join(',', @interfaces);
		}
	
		if ( $type == 2 )
		{
			$circuit = ActiveCMDB::Object::Circuit::FrDlci->new(device_id => $device_id, ifindex => $ifindex, dlci=> $circuit_id);
			$circuit->get_data();
		
			$json->{circuitName} = $circuit->dlci;
			$json->{circuitDesc} = $circuit->type;
			$json->{circuitLow}  = $circuit->dlcistr;
			$json->{circuitHigh} = $circuit->burst;
			my @interfaces = ();
			my $int = ActiveCMDB::Object::ifEntry->new(device_id => $device_id, ifindex => $ifindex);
			$int->get_data();
			push(@interfaces, $int->ifname());
			$json->{cicuitUnits} = join(',', @interfaces);
		}
	
		$c->stash->{json} = $json;
		$c->forward( $c->view('JSON') );
	} else {
		$c->log->warn("Unauthorized");
	}
}


sub delete_device :Local {
	my($self, $c) = @_;
	
	if ( cmdb_check_role($c,qw/deviceAdmin/) )
	{
		my $device_id  = $c->request->params->{device_id};
		my $device = ActiveCMDB::Object::Device->new(device_id => $device_id);
		$device->get_data();
		# The device should not be deleted from the database, rather is should be
		# marked for deletion and the distribution server should be signalled
		#
		$c->log->info("Setting device status to 3");
		$device->status(3);
		$device->save();
	
		my $p = { 
			device => {  
				device_id  => $device_id,
				hostname   => $device->hostname,
				mgtaddress => $device->mgtaddress
			},
			user => $c->user->get('username')
		
		};
		my $broker = ActiveCMDB::Common::Broker->new( $config->section('cmdb::broker') );
		$broker->init({ process => 'web'.$$ , subscribe => false });
		my $message = ActiveCMDB::Object::Message->new();
		$message->from('web'.$$ );
		$message->subject('DeleteDevice');
		$message->to($config->section("cmdb::process::object::exchange"));
		$message->payload($p);
		$c->log->debug("Sending message to " . $message->to );
		$broker->sendframe($message,{ priority => PRIO_HIGH } );
	
		$c->response->body("Failed to update device parameters");
		$c->response->status(200);
	} else {
		$c->response->body("Unauthorized");
		$c->response->status(401)
	}
}

sub search :Local {
	my($self, $c) = @_;
	if ( cmdb_check_role($c,qw/deviceViewer deviceAdmin/) )
	{
		$c->stash->{template} = 'device/search_container.tt';
	}
}

sub api :Local {
	my($self, $c) = @_;
	if ( cmdb_check_role($c,qw/deviceViewer deviceAdmin/) )
	{
		if ( defined($c->request->params->{oper}) ) {
			$c->forward($c->request->params->{oper});
		} else {
			$c->log->warn("Forward operation not defined");
		}
	}
}

sub list :Local {
	my($self, $c) = @_;
	
	if ( cmdb_check_role($c,qw/deviceViewer deviceAdmin/) )
	{
		my($json,$rs);
		my @rows = ();
		my %schemes = ();
	
		$json = undef;
	
		my $rows	= $c->request->params->{rows} || 10;
		my $page	= $c->request->params->{page} || 1;
		my $order	= $c->request->params->{sidx} || 'hostname';
		my $asc		= '-' . $c->request->params->{sord};
		my $search = undef;
	
		my $options = {
			rows		=> $rows,
			page		=> $page,
			order		=> $order,
		};
	
		#
		# Create search filter
		#
	
		my $orderBy		 = undef;
		if ( $c->request->params->{_search} eq 'true' )
		{
			my $searchOper   = $c->request->params->{searchOper};
			my $searchField  = $c->request->params->{searchField};
			my $searchString = $c->request->params->{searchString};
				
			if ( $searchField eq 'vendor' )
			{
				$searchField = "vendors.vendor_name";
			}
		
			if ( $searchField eq 'site' )
			{
				$searchField = "location.name";
			}
		
			if ( $searchField eq 'type')
			{
				$searchField = "sysoids.descr";
			}
		
			switch ( $searchOper ) {
				case 'cn'		{ $search = { $searchField => { like => '%'.$searchString.'%' } } }
				case 'eq'		{ $search = { $searchField => $searchString } }
				case 'ne'		{ $search = { $searchField => { '!=' => $searchString } } }
				case 'bw'		{ $search = { $searchField => { like => $searchString.'%' } } }
				else 			{ $search = { } }
			}
		
		} else {
			$search = { };
		}
	
		switch ( $order ) {
				case 'vendor'	{ $orderBy = 'vendor.vendor_name' }
				case 'type'		{ $orderBy = 'sysoids.descr' }
				case 'site'		{ $orderBy = 'location.name '}
				else { $orderBy = $order }
		}
	
		my $join         = { 'sysoids' => 'vendors'  };
		$rs = $c->model("CMDBv1::IpDevice")->search(
				$search,
				{
					'+select'	=> [ 'location.name', 'vendors.vendor_name', 'sysoids.descr' ],
					'+as'		=> [ 'site_name', 'vendor_name', 'dev_type'],
					join		=> [ $join, 'location' ],
					order_by		=> { $asc => $orderBy }
				}
			);
	
		$json->{records} = $rs->count;
		if ( $json->{records} > 0 ) {
			$json->{total} = ceil($json->{records} / $c->request->params->{rows} );
		} else {
			$json->{total} = 0;
		} 
		@rows = ();
		while ( my $row = $rs->next )
		{
			push(@rows, { id => $row->device_id, cell=> [
															$row->hostname,
															$row->mgtaddress,
															$row->get_column('vendor_name'),
															$row->get_column('dev_type'),
															$row->get_column('site_name')
												]
						}
				);
		}
	
		$json->{rows} = [ @rows ];
		$c->stash->{json} = $json;
		$c->forward( $c->view('JSON') );
	} else {
		$c->log->warn("Unauthorized");
	}
}

1;