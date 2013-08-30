package ActiveCMDB::Controller::Roles;

=begin nd

    Script: ActiveCMDB::Controller::Roles.pm
    ___________________________________________________________________________

    Version 1.0

    Copyright (C) 2011-2015 Theo Bot

    http://www.activecmdb.org


    Topic: Purpose

    Catalyst Controller for managing roles

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

use Moose;
use namespace::autoclean;
use POSIX;
use Switch;
use Try::Tiny;
BEGIN { extends 'Catalyst::Controller'; }

=head2 index

=cut

sub index : Private {
    my ( $self, $c ) = @_;

	if ( $c->check_user_roles('admin'))
	{
		$c->stash->{template} = 'roles/role_container.tt';
	} else {
		$c->response->redirect($c->uri_for($c->controller('Root')->action_for('noauth')));
	}
}

sub api: Local {
	my($self, $c) = @_;

	if ( $c->check_user_roles('admin'))
	{	
		if ( defined($c->request->params->{oper}) ) {
			$c->forward('/roles/' . $c->request->params->{oper});
		}
	} else {
		$c->response->redirect($c->uri_for($c->controller('Root')->action_for('noauth')));
	}
}

sub edit :Local {
	my( $self, $c ) = @_;
	
	if ( $c->check_user_roles('admin'))
	{
		my $role_id = $c->request->params->{id} || 0;
	
		$c->stash->{role} = $c->model('CMDBv1::Role')->find({ id => $role_id });
		$c->stash->{template} = 'roles/edit.tt';
	} else {
		$c->response->redirect($c->uri_for($c->controller('Root')->action_for('noauth')));
	}
}

sub add :Local {
	my( $self, $c ) = @_;
	
	if ( $c->check_user_roles('admin'))
	{
		my $role_id = $c->request->params->{id} || 0;
	
		$c->stash->{template} = 'roles/edit.tt';
	} else {
		$c->response->redirect($c->uri_for($c->controller('Root')->action_for('noauth')));
	}
}

sub create :Local {
	my($self, $c) = @_;
	
	if ( $c->check_user_roles('admin'))
	{
		my $role = $c->request->params->{role} || "";
	
		my $rs = $c->model('CMDBv1::Role')->create({ role => $role });
	
		$c->response->redirect($c->uri_for($c->controller('Roles')->action_for('index')));
	} else {
		$c->response->redirect($c->uri_for($c->controller('Root')->action_for('noauth')));
	}
}

sub save :Local {
	my($self, $c) = @_;
	my($rs,$id,$role);
	
	if ( $c->check_user_roles('admin'))
	{
		$id = $c->request->params->{id} || 0;
		$role = $c->request->params->{role} || "";
	
		if ( $role ne 'admin' && $role ne '' && $id != 1) 
		{
			try {
			
				$rs = $c->model('CMDBv1::Role')->update_or_create(
							{
								id => $id,
								role => $role
							}
						);

				if ( ! $rs->in_storage ) {
					$rs->insert;
					$c->response->body('Role created');
				} else {
					$c->response->body('Role updated');
				}
			} catch {
				$c->response->body('Failed to update role');
			};
		} else {
			$c->response->body('Unable to update admin role');
		}
	} else {
		$c->response->redirect($c->uri_for($c->controller('Root')->action_for('noauth')));
	}
}

sub delete :Local {
	my($self, $c) = @_;
	my($id,$rs);
	
	$id = $c->request->params->{id} || 0;
	
	if ( $id > 1 )
	{
		try {
			$rs = $c->model('CMDBv1::Role')->find({ id => $id } );
			if ( defined($rs) ) {
				$rs->delete;
			}
			$c->response->body('Role deleted');
		} catch {
			$c->response->body('Failed to delete role');
		}
	} else {
		$c->response->body('Unable to delete admin role');
	}
	
	
}

sub list: Local {
	my($self, $c) = @_;
	my($rs,$json);
	my @rows = ();
	my $rows	= $c->request->params->{rows} || 10;
	my $page	= $c->request->params->{page} || 1;
	my $order	= $c->request->params->{sidx} || 'role';
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
	
	
	$rs = $c->model("CMDBv1::Role")->search(
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
		push(@rows, { id => $row->id, cell=> [
														$row->id,
														$row->role
											]
					}
			);
	}
	
	$json->{rows} = [ @rows ];
	$c->stash->{json} = $json;
	$c->forward( $c->view('JSON') );
}

__PACKAGE__->meta->make_immutable;

1;
