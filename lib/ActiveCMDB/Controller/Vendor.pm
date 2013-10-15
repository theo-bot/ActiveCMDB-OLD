package ActiveCMDB::Controller::Vendor;

=head1 MODULE - ActiveCMDB::Controller::Vendor
    ___________________________________________________________________________

=head1 VERSION

    Version 1.0

=head1 COPYRIGHT

    Copyright (C) 2011-2015 Theo Bot

    http://www.activecmdb.org


=head1 DESCRIPTION

    Catalyst Controller for managing vendors

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
 use Try::Tiny;
 use Data::Dumper;
=cut

use Moose;
use namespace::autoclean;
use Try::Tiny;
use Data::Dumper;
use Switch;
use POSIX;
use ActiveCMDB::Object::Vendor;
use ActiveCMDB::Common::Vendor;

BEGIN { extends 'Catalyst::Controller'; }

=head1 METHODS

=head2 index

=cut

sub index :Private {
    my ( $self, $c ) = @_;

	#
	# Get all vendors for schema
	#
	$c->stash->{vendors} = [ $c->model('CMDBv1::Vendor')->all ];
	
	#
	# Add admin flag to template
	#
	if ( $c->check_user_roles('vendorAdmin') )
	{
		$c->stash->{admin} = 1;
	} else {
		$c->stash->{admin} = 0;
	} 
    #
    # Add proper template
    #
    $c->stash->{template} = 'vendor/list.tt';
}

sub api :Local {
	my($self, $c) = @_;
	
	if ( defined($c->request->params->{oper}) ) {
		$c->forward('/vendor/' . $c->request->params->{oper});
	}
}

sub list :Local {
	my($self, $c) = @_;
	my($rs, $json, $search);
	my @rows = ();
	
	my $rows	= $c->request->params->{rows} || 10;
	my $page	= $c->request->params->{page} || 1;
	my $order	= $c->request->params->{sidx} || 'vendor_name';
	my $asc		= '-' . $c->request->params->{sord};
	
	#
	# Create search filter
	#
	if ( $c->request->params->{_search} eq 'true' )
	{
		my $searchOper   = $c->request->params->{searchOper};
		my $searchField  = $c->request->params->{searchField};
		my $searchString = $c->request->params->{searchString};
		
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
	$c->log->debug(Dumper($search));
	
	$rs = $c->model("CMDBv1::Vendor")->search(
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
	
	while ( my $row = $rs->next )
	{
		
		push(@rows, { id => $row->vendor_id, cell=> [
														$row->vendor_name,
														$row->vendor_support_phone,
														$row->vendor_support_email,
														$row->vendor_support_www
													]
					}
			);
	}
	
	$c->log->debug(Dumper(\@rows));
	
	$json->{rows} = [ @rows ];
	$c->stash->{json} = $json;
	$c->forward( $c->view('JSON') );
}

=head2 view

View or edit vendor data
=cut
sub edit :Local {
	my( $self, $c ) = @_;
	my($vendor, $id);
	#
	# Get vendor data
	#
	$id = int($c->request->params->{id});
	$c->log->info("Fetching data for $id");
	$vendor = ActiveCMDB::Object::Vendor->new(id => $id);
	$vendor->get_data();
	$c->log->info("Found vendor " . $vendor->name);
	
	$c->stash->{vendor} = $vendor;
	
	if ( $c->check_user_roles('vendorAdmin') )
	{
		$c->stash->{template} = 'vendor/edit.tt';
	} else {
		if ( $id > 0 ) {
			$c->stash->{template} = 'vendor/view.tt';
		}
	}
	
}

=head2 add :Local

Add a new vendor

=cut
sub add :Local {
	my($self, $c) = @_;
	my($vendor);
	
	$vendor = ActiveCMDB::Object::Vendor->new();
	$c->stash->{vendor} = $vendor;
	if ( $c->check_user_roles('vendorAdmin') )
	{
		$c->stash->{template} = 'vendor/edit.tt';
	} else {
		$c->stash->{template} = 'un_authorized.tt';
	}
}

=head2 save

Save vendor data
=cut
sub save :Local {
	my( $self, $c ) = @_;
	my($vendor);
	
	if ( $c->check_user_roles('vendorAdmin') )
	{
		$vendor = ActiveCMDB::Object::Vendor->new();
		
		if ( defined($c->request->params->{id}) && $c->request->params->{id} eq "" ) {
			$c->request->params->{id} = undef;
		}
		
		$vendor->populate($c->request->params);
		my $res = $vendor->save();
		$c->response->body($res);
		
	} else {
		$c->response->redirect($c->uri_for($c->controller('Root')->action_for('noauth')));
	}
}

__PACKAGE__->meta->make_immutable;

1;
