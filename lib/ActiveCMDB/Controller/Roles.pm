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
use Try::Tiny;
BEGIN { extends 'Catalyst::Controller'; }

=head2 index

=cut

sub index : Private {
    my ( $self, $c ) = @_;

	if ( $c->check_user_roles('admin'))
	{
		$c->stash->{roles} = [ $c->model('CMDBv1::Role')->all ];

		$c->stash->{template} = 'roles/list.tt';
	} else {
		$c->response->redirect($c->uri_for($c->controller('Root')->action_for('noauth')));
	}
}

sub edit :Local {
	my( $self, $c ) = @_;
	
	if ( $c->check_user_roles('admin'))
	{
		my $role_id = $c->request->params->{role_id} || 0;
	
		$c->stash->{role} = $c->model('CMDBv1::Role')->find({ id => $role_id });
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

__PACKAGE__->meta->make_immutable;

1;
