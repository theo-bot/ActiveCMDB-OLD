package ActiveCMDB::Controller::Location;

=begin nd

    Script: ActiveCMDB::Controller::Location.pm
    ___________________________________________________________________________

    Version 1.0

    Copyright (C) 2012-2013 Theo Bot

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
use ActiveCMDB::ConfigFactory;
use ActiveCMDB::Common::Conversion;
use ActiveCMDB::Common::Location;
use ActiveCMDB::Object::Location;

BEGIN { extends 'Catalyst::Controller'; }

sub index :Private {
    my ( $self, $c ) = @_;
	my @sitetypes = ();

	my $config = ActiveCMDB::ConfigFactory->instance();
	$config->load('cmdb');
	
	my $sitetypes = $config->section('cmdb::location::types');
	
	$c->log->debug(Dumper($sitetypes));
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
	
	$site = ActiveCMDB::Object::Location->new(location_id => $c->request->params->{location_id} || undef);
	foreach my $key ($site->meta->get_all_attributes)
	{
		my $attr = $key->name;
		next if ( /location_id|schema/ );
		$site->$attr($c->request->params->{$attr});
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
		$c->log->error("Failed to save site: " . $_);
		$c->response->body("Failed to save site information");
	}
	
}

=head1 AUTHOR

Theo Bot

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
