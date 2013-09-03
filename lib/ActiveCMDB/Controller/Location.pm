package ActiveCMDB::Controller::Location;

=begin nd

    Script: ActiveCMDB::Controller::Location.pm
    ___________________________________________________________________________

    Version 1.0

    Copyright (C) 2011-2015 Theo Bot

    http://www.activecmdb.org


    Topic: Purpose

    Catalyst Controller for managing sites/locations

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
	
	This module performs actions on the conversions table
	
	
=cut

#########################################################################
# Initialize  modules

use Moose;
use namespace::autoclean;
use Try::Tiny;
use Data::Dumper;
use Switch;
use POSIX;
use Logger;
use ActiveCMDB::ConfigFactory;
use ActiveCMDB::Common::Conversion;
use ActiveCMDB::Common::Location;
use ActiveCMDB::Object::Location;

BEGIN { extends 'Catalyst::Controller'; }

sub index :Private {
    my ( $self, $c ) = @_;
    
	$c->stash->{template} = 'location/site_container.tt';
}

sub api: Local {
	my($self, $c) = @_;

	if ( $c->check_user_roles('admin'))
	{	
		if ( defined($c->request->params->{oper}) ) {
			$c->forward('/location/' . $c->request->params->{oper});
		}
	} else {
		$c->response->redirect($c->uri_for($c->controller('Root')->action_for('noauth')));
	}
}

sub edit: Local
{
	my($self, $c) = @_;
	my @sitetypes = ();
	my $config = ActiveCMDB::ConfigFactory->instance();
	$config->load('cmdb');
	
	my $sitetypes = $config->section('cmdb::location::types');
	foreach my $key (sort keys %$sitetypes)
	{
		push(@sitetypes, { id => $key, name => $sitetypes->{$key}} );
	}
	
	$c->stash->{types} = [ @sitetypes ];
	$c->stash->{classifs} = [ cmdb_list_byname('siteClass') ];
	
	my $id = int($c->request->params->{id});
	
	if ( $id ) {
		my $site = ActiveCMDB::Object::Location->new(location_id => $id);
		$site->get_data();
		$c->stash->{site} = $site;
		my @parents = get_site_parents($site->location_type);
		$c->stash->{parents} = [ @parents ];
		
	}
	
	
	$c->stash->{template} = 'location/view.tt';
}

sub add :Local {
	my($self,$c) = @_;
	my @sitetypes = ();
	my $config = ActiveCMDB::ConfigFactory->instance();
	$config->load('cmdb');
	
	my $sitetypes = $config->section('cmdb::location::types');
	foreach my $key (sort keys %$sitetypes)
	{
		push(@sitetypes, { id => $key, name => $sitetypes->{$key}} );
	}
	
	$c->stash->{types} = [ @sitetypes ];
	$c->stash->{classifs} = [ cmdb_list_byname('siteClass') ];
	
	$c->stash->{template} = 'location/view.tt';
}

sub find_by_name :Local {
	my($self,$c) = @_;
	
	$c->stash->{current_view} = 'JSON';
	
	my $name  = $c->request->params->{name_startsWith} || "";
	my $limit = $c->request->params->{maxRows} || 10;
	
	my $rs = $c->model('CMDBv1::Location')->search(
				{
					name => { like => $name.'%'}
				},
				{
					rows => $limit
				}
		);
	my @names = ();
	while ( my $row = $rs->next ) {
		push(@names, { id => $row->location_id, label => $row->name } );
	}
	#$c->log->debug(Dumper(@names));
	
	$c->stash->{json} = { names => \@names };
	$c->forward( $c->view('JSON') );
	
	
}

sub fetch_by_name :Local {
	my ($self, $c) = @_;
	my($siteRow, $name,$parent, $site);
	my $data = undef;
	
	$c->stash->{current_view} = 'JSON';
	
	$name = $c->request->params->{name} || "";
	
	$siteRow = $c->model('CMDBv1::Location')->find(
		{ 
			name => $name 
		},
		{
			columns => 'location_id'
		}
		
	);
	if ( defined($siteRow) ) {
		$site = ActiveCMDB::Object::Location->new(location_id => $siteRow->location_id);
		$site->get_data();
	} else {
		$site = ActiveCMDB::Object::Location->new();
	}
	
	$data = $site->to_hashref();
	
	
	
	#
	# If the place is not defined get the parent's place
	#
	$data->{place} = $site->place();
	
	
	#
	# Construct the parent tree
	#
	$data->{parentString} = $site->site_parent();
	
	
	$c->stash->{json} = { site => $data };
	$c->forward( $c->view('JSON') );
}

sub fetch_by_id :Local {
		my($self,$c) = @_;
		
		# Initialize variables
		my($id,$site,$json);
		
		$id = $c->request->params->{id} || 0;
		$json = undef;
		
		if ( $id > 0 )
		{
			$site = ActiveCMDB::Object::Location->new(location_id => $id );
			$site->get_data();
			
			$json = $site->to_hashref();
			
			$json->{parentStr} = $site->site_parent();
			$json->{place} = $site->place;
		}
		
		$c->stash->{json} = $json;
		$c->forward( $c->view('JSON') );
}
	

sub get_parents :Local {
	my($self, $c) = @_;
	my($row,$rs,$type,$id, $parent_id);
	
	my @parents = ();
	$type = $c->request->params->{type} || 0;
	$id   = $c->request->params->{location_id} || 0;
	
	$row = $c->model('CMDBv1::location')->find({ location_id => $id });
	if ( defined($row) ) {
		$parent_id = $row->parent_id;
	}
	
	$rs = $c->model('CMDBv1::Location')->search(
			{
				type => { '<' => $type }
			}
	);
	while ( my $row = $rs->next ) {
		push(@parents, { optionValue => $row->location_id, optionDisplay => $row->name });
	}
	
	$c->stash->{json} = { parents => \@parents, parent_id => $parent_id };
	$c->forward( $c->view('JSON') );
}

sub save :Local {
	my($self,$c) = @_;
	my($site, $rs);
	
	if ( defined($c->request->params->{location_id}) && int($c->request->params->{location_id}) > 0 )
	{
		$site = ActiveCMDB::Object::Location->new(location_id => $c->request->params->{location_id});
		$site->get_data();
	} else {
		$site = ActiveCMDB::Object::Location->new();
	}
	
	foreach my $key ($site->meta->get_all_attributes)
	{
		my $attr = $key->name;
		next if ( $attr =~ /location_id|schema/ );
		if ( defined($c->request->params->{$attr}) ) {
			Logger->debug("Populating $attr");
			$site->$attr($c->request->params->{$attr});
		}
	}
	
	
	if ( ! defined($site->location_id) && defined($site->name) )
	{
		my $count = $c->model('CMDBv1::Location')->search({ name => $site->name })->count;
		if ( $count > 0 )
		{
			$c->response->body("Sitename already in use");
			return;
		}
	}	
	
	
	if ( $site->save() )
	{
		$c->response->body("Saved site information");
	} else {
		
		$c->response->body("Failed to save site information");
	}
	
}


sub list: Local {
	my($self, $c) = @_;
	my($rs,$json);
	my @rows = ();
	my $rows	= $c->request->params->{rows} || 10;
	my $page	= $c->request->params->{page} || 1;
	my $order	= $c->request->params->{sidx} || 'username';
	my $asc		= '-' . $c->request->params->{sord};
	my $search = undef;

	if ( defined($c->request->params->{_search}) && $c->request->params->{_search} eq 'true' )
	{
		my $field  = $c->request->params->{searchField};
		my $string = $c->request->params->{searchString};
		
		switch ( $c->request->params->{searchOper})
		{
			case "cn"	{ $search = { $field => { 'like' => '%'.$string.'%' } } }
			case "eq"	{ $search = { $field => $string } }
			case "ne"	{ $search = { $field => { '!=' => $string } } }
		}
	}
	
	
	$rs = $c->model("CMDBv1::Location")->search(
				$search,
				{
					rows		=> $rows,
					page		=> $page,
					order_by	=> { $asc => $order },
				}
	);
	
	$json->{records} = $rs->count;
	if ( $json->{records} > 0 ) {
		$json->{total} = ceil($json->{records} / $c->request->params->{rows} );
	} else {
		$json->{total} = 0;
	} 
	
	my $config = ActiveCMDB::ConfigFactory->instance();
	$config->load('cmdb');
	
	my $sitetypes = $config->section('cmdb::location::types');
	
	while ( my $row = $rs->next )
	{
		push(@rows, { id => $row->location_id, cell=> [
														$row->name,
														$sitetypes->{$row->location_type},
														$row->primary_contact,
														$row->primary_phone
											]
					}
			);
	}
	
	$json->{rows} = [ @rows ];
	$c->stash->{json} = $json;
	$c->forward( $c->view('JSON') );
}

=head1 AUTHOR

Theo Bot

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
