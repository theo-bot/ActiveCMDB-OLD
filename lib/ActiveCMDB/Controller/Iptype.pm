package ActiveCMDB::Controller::Iptype;

=begin nd

    Script: ActiveCMDB::Controller::Iptype.pm
    ___________________________________________________________________________

    Version 1.0

    Copyright (C) 2011-2015 Theo Bot

    http://www.activecmdb.org


    Topic: Purpose

    Manage IP Device Types

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

use Moose;
use namespace::autoclean;
use POSIX;
use MIME::Base64;
use Image::Info qw(image_info dim);
use Data::Dumper;
use ActiveCMDB::Common::Security;
use ActiveCMDB::Common::Constants;
use ActiveCMDB::Common::IpType;
use ActiveCMDB::Object::IpType;
use ActiveCMDB::Common::Vendor;
use ActiveCMDB::Common::Conversion;

BEGIN { extends 'Catalyst::Controller'; }

sub index :Private {
    my ( $self, $c ) = @_;
	
	if ( cmdb_check_role($c,qw/deviceViewer deviceAdmin/) )
	{
		$c->stash->{template} = 'device/type_container.tt';
	} else {
		$c->response->redirect($c->uri_for($c->controller('Root')->action_for('noauth')));
	}
}

sub api :Local {
	my($self, $c) = @_;
	
	if ( defined($c->request->params->{oper}) ) {
		$c->forward($c->request->params->{oper});
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
		my $order	= $c->request->params->{sidx} || 'domain_id';
		my $asc		= '-' . $c->request->params->{sord};
		my $search = undef;
	
		#
		# Get total for the query
		#
		#$c->log->debug("$search");
		$json->{records} = $c->model('CMDBv1::IpDeviceType')->search( {} , { join => 'vendors'} )->count;
		if ( $json->{records} > 0 ) {
			$json->{total} = ceil($json->{records} / $rows );
		} else {
			$json->{total} = 0;
		} 
	
		#
		# Get the data
		#
		if ( $order =~ /vendor_name/ ) {
			$order = 'vendors.'.$order;
		} else {
			$order = 'me.'.$order;
		}
	
		$rs = $c->model('CMDBv1::DiscoScheme')->search({},{ order_by => 'name' });
		while (my $row = $rs->next)
		{
			$schemes{$row->scheme_id} = $row->name;
		}
		#$c->log->debug(Dumper(%schemes));
	
		$rs = $c->model('CMDBv1::IpDeviceType')->search(
					$search,
					{
						join	 => 'vendors',
						order_by => { $asc => $order },
						rows	 => $rows,
						page	 => $page,
						select	 => [qw/type_id descr sysobjectid active disco_scheme vendors.vendor_name /],
						as		 => [qw/type_id descr sysobjectid active disco_scheme name/]
					}
				);
			
		while ( my $row = $rs->next )
		{
			$c->log->debug(sprintf("Type_id %d has model %d",$row->type_id, $row->disco_scheme));
			push(@rows, { id => $row->type_id, cell=> [	
															$row->descr,
															$row->sysobjectid,
															$row->active,
															$row->get_column('name'),
															$schemes{ $row->disco_scheme } || "",								
														] 
						}
				);
		}
		$json->{rows} = [ @rows ];
		#$c->log->debug(Dumper($json));
		$c->stash->{json} = $json;
	
		$c->forward( $c->view('JSON') );
	} else {
		$c->response->redirect($c->uri_for($c->controller('Root')->action_for('noauth')));
	}
}

sub del :Local {
	my($self,$c) = @_;
	
	if ( cmdb_check_role($c,qw/deviceAdmin/) )
	{
		my($iptype,$id);
	
		$id = $c->request->params->{id};
		$iptype = get_iptype_by_typeid($id);
		if ( defined($iptype) && $iptype->descr ne 'GenericSnmp') {
			$iptype->delete();
			$c->response->status(HTTP_OK);
		} else {
			$c->response->status(HTTP_INTERNAL_ERROR);
		}
	
		
		$c->response->body('');
	} else {
		$c->response->status(HTTP_UNAUTHORIZED);
		$c->response->body('');
	}
}

sub image :Local {
	my($self, $c) = @_;
	
	if ( cmdb_check_role($c,qw/deviceViewer deviceAdmin/) )
	{
		my($id,$type);
	
		$id = $c->request->params->{id};
		$c->log->debug("Fetching image data for $id");
		$type = get_iptype_by_typeid($id);
		
		if ( defined($type) && ref($type) eq 'ActiveCMDB::Object::IpType' ) {
			$c->log->info("Fetching image data");
			if ( $type->image->get_data() )
			{
				$c->log->info("Image mimetype " . $type->image->mime_type);
				$c->stash->{image} = $type->image->image;
				$c->stash->{mimetype} = $type->image->mime_type;
			} else {
				$c->log->warn("No image data available");
			}
		} else {
			$c->log->info("No image data found for $id");
		}
		$c->stash->{type_id} = $id;
		$c->stash->{template} = 'device/type_image.tt';
	} else {
		$c->response->redirect($c->uri_for($c->controller('Root')->action_for('noauth')));
	}
}

sub storeimage :Local {
	my($self, $c) = @_;
	
	if ( cmdb_check_role($c,qw/deviceAdmin/) )
	{
		my($data,$upload);
	
		$upload = $c->request->upload('image');
	
		if ( defined($upload) )
		{
			my $tmpfile = $upload->tempname;
			my $info = image_info($tmpfile);
			if ( my $error = $info->{error} ) 
			{
				$c->log->warn("Can't parse image file: ". $error);
				$c->forward('image');
			}
			if ( $info->{file_media_type} =~ /jpg|jpeg|png/ )
			{
				my $type = get_iptype_by_typeid($c->request->params->{id});
				$type->image->mime_type($upload->type);
				$type->image->image(encode_base64($upload->slurp));
				$type->image->save();
			} else {
				$c->log->warn("Attempt to upload invalid file type");
			}
		} else {
			$c->log->warn("Undefined upload");
		}
		$c->forward('image');
	} else {
		$c->response->redirect($c->uri_for($c->controller('Root')->action_for('noauth')));
	}
}

sub view :Local {
	my($self, $c) = @_;
	
	if ( cmdb_check_role($c,qw/deviceAdmin/) )
	{
		my $id = $c->request->params->{type_id};
	
		my $type = get_iptype_by_typeid($id);
		$c->log->debug(ref $type);
		if ( defined($type) && ref($type) eq 'ActiveCMDB::Object::IpType')
		{
			$c->log->info("Fetched data for a " . $type->descr);
			$c->stash->{iptype} = $type;
		}	
		$c->stash->{schemas} = [ get_disco_schemes() ];
	
		my %vendors = cmdb_get_vendors();
		my %netTypes = cmdb_name_set("networkType");
		$c->stash->{vendors} = \%vendors;
		$c->stash->{netTypes} = \%netTypes;
		
		$c->stash->{template} = 'device/type_view.tt';
	} else {
		$c->response->redirect($c->uri_for($c->controller('Root')->action_for('noauth')));
	}
}

sub save :Local {
	my($self, $c) = @_;
	my $type;
	
	if ( cmdb_check_role($c,qw/deviceAdmin/) )
	{
		my $id = $c->request->params->{type_id};
		if ( defined($id) && int($id) > 0 )
		{
			$type = get_iptype_by_typeid($id);
			if ( $type->descr eq 'GenericSnmp' ) {
				$c->response->status(HTTP_INTERNAL_ERROR);
				$c->response->body('');
				return;
			}
		} else { 
			$type = ActiveCMDB::Object::IpType->new();
		}
		foreach my $attr (keys %{$type->map})
		{
			if ( defined($c->request->params->{$attr}) && $type->meta->get_attribute( $attr )->get_write_method  )
			{
				$type->$attr( $c->request->params->{$attr} )
			}
		}
		if ( $type->save() )
		{
			$c->response->status(HTTP_OK);
		} else {
			$c->response->status(HTTP_INTERNAL_ERROR);
		}
	} else {
		$c->response->status(HTTP_UNAUTHORIZED);
	}
	$c->response->body('');
}

=head1 AUTHOR

Theo Bot

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
