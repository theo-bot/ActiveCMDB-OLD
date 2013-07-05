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

BEGIN { extends 'Catalyst::Controller'; }


sub index :Private {
    my ( $self, $c ) = @_;
	
	
	$c->stash->{template} = 'device/type_container.tt';
   
}

sub api :Local {
	my($self, $c) = @_;
	
	if ( defined($c->request->params->{oper}) ) {
		$c->forward($c->request->params->{oper});
	}
}

sub list :Local {
	my($self, $c) = @_;
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
	
}

sub edit :Local {
	my($self, $c) = @_;
	my($data,$f);
	
	$data = undef;
	foreach $f (qw/active descr disco_scheme sysobjectid vendor_id/)
	{
		
		$data->{$f} = $c->request->params->{$f};
		
	}
	$data->{type_id} = $c->request->params->{id} || undef;
	
	$c->model("CMDBv1::IpDeviceType")->update_or_create( $data );
	
	$c->response->status(200);
	$c->response->body('');
}

sub add :Local {
	my($self, $c) = @_;
	my($data, $f);
	
	$data = undef;
	foreach $f (qw/active descr disco_scheme sysobjectid vendor_id/)
	{
		$data->{$f} = $c->request->params->{$f};
	}
	$data->{type_id} = undef;
	
	$c->model("CMDBv1::IpDeviceType")->create( $data );
	
	$c->response->status(200);
	$c->response->body('');
}

sub del :Local {
	my($self,$c) = @_;
	my($row,$id);
	
	$id = $c->request->params->{id};
	$row = $c->model("CMDBv1::IpDeviceType")->find({ type_id => $id });
	if ( defined($row) ) {
		$row->delete;
	} else {
		$c->log->warn("type_id $id not found to delete");
	}
	
	$c->response->status(200);
	$c->response->body('');
}

=item vendors

vendors - Get vendors to fill select option

=cut

sub vendors :Local {
	my($self, $c) = @_;
	my($rs,$data);
	
	$data = "<select>";
	$rs = $c->model('CMDBv1::Vendor')->search({}, {order_by => 'vendor_name'});
	while (my $row = $rs->next)
	{
		$data .= sprintf("<option value='%d'>%s</option>", $row->vendor_id, $row->vendor_name);
	}
	$data .= "</select>";
	
	$c->response->body( $data );
	
}

sub disco :Local {
	my($self, $c) = @_;
	my($rs, $data);
	
	$data = "<select>";
	$rs = $c->model('CMDBv1::DiscoScheme')->search();
	while (my $row = $rs->next)
	{
		$data .= sprintf("<option value='%d'>%s</option>", $row->scheme_id, $row->name);
	}
	$data .= "</select>";
	
	$c->response->body($data);
}

sub image :Local {
	my($self, $c) = @_;
	my($id,$row);
	
	$id = $c->request->params->{id};
	$c->log->debug("Fetching image data for $id");
	$row = $c->model("CMDBv1::IpDeviceTypeImage")->find({ type_id => $id });
	if ( defined($row) ) {
		$c->stash->{image} = $row->image;
		$c->stash->{mimetype} = $row->mime_type;
	} else {
		$c->log->info("No image data found for $id");
	}
	$c->stash->{type_id} = $id;
	$c->stash->{template} = 'device/type_image.tt';
}

sub storeimage :Local {
	my($self, $c) = @_;
	my($data,$upload);
	
	$data = undef;
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
			$data->{type_id} 	= $c->request->params->{id};
			$data->{mime_type}	= $upload->type;
			$data->{image}		= encode_base64($upload->slurp);
			
			$c->model("CMDBv1::IpDeviceTypeImage")->update_or_create($data);
		} else {
			$c->log->warn("Attempt to upload invalid file type");
		}
	} else {
		$c->log->warn("Undefined upload");
	}
	$c->forward('image');
}

=head1 AUTHOR

Theo Bot

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
