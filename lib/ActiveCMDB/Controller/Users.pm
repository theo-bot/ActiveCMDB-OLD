package ActiveCMDB::Controller::Users;

=begin nd

    Script: ActiveCMDB::Controller::Users.pm
    ___________________________________________________________________________

    Version 1.0

    Copyright (C) 2011-2015 Theo Bot

    http://www.activecmdb.org


    Topic: Purpose

    Catalyst Controller for managing users

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
use Data::Dumper;
use POSIX;
use Switch;
use Try::Tiny;

BEGIN { extends 'Catalyst::Controller'; }

=head2 index

=cut

sub index :Private {
	my($self, $c) = @_;
	
	if ( $c->check_user_roles('admin') )
	{
		$c->log->info("Listing all users");
		$c->stash->{template} = 'users/user_container.tt';
		
	} else {
		$c->log->info("Fetching current user");
		$c->stash->{template} = 'users/user_password.tt';
	}
	
	
	#$c->log->info("Found " . scalar(@{$c->stash->{users}}) . " objects");
	#$c->stash->{template} = 'users/list.tt';
}

sub api: Local {
	my($self, $c) = @_;

	if ( $c->check_user_roles('admin'))
	{	
		if ( defined($c->request->params->{oper}) ) {
			$c->forward('/users/' . $c->request->params->{oper});
		}
	} else {
		$c->response->redirect($c->uri_for($c->controller('Root')->action_for('noauth')));
	}
}

sub edit :Local {
	my($self, $c) = @_;
	my($user_id);
	
	$user_id = $c->request->params->{id} || 0;
	
	$c->stash->{user} = $c->model('CMDBv1::User')->find({ id => $user_id });
	
	if ( $c->check_user_roles('admin'))
	{
		my $rs = $c->model('CMDBv1::UserRole')->search({ user_id => $user_id });
		my @assigned  = ();
		my @available = ();
		my @h = ();
		while ( my $row = $rs->next )
		{
			push(@assigned, { id => $row->role_id, role => $row->role->role });
			push(@h, $row->role_id);
		}
		$rs = $c->model('CMDBv1::Role')->search({ id => { 'NOT IN' => [ @h ] } });
		while ( my $row = $rs->next )
		{
			push(@available, { id => $row->id, role => $row->role });
		}
		
		$c->stash->{available} = [ @available ];
		$c->stash->{assigned} = [ @assigned ];
		$c->stash->{template} = 'users/edit.tt';
	} else {
		$c->stash->{template} = 'users/passwd.tt';
	}
}

sub save :Local {
	my($self, $c) = @_;
	my @userRoles = ();
	my($user_id, $transaction, $row, $rs, $user);
	$c->log->info(Dumper($c->request->params));
	
	if ( defined($c->request->params->{userRoles}) )
	{
		if ( ref $c->request->params->{userRoles} eq 'ARRAY' )
		{
			foreach my $role (@{$c->request->params->{userRoles}})
			{
				push(@userRoles, int($role));
			} 
		} else {
			push(@userRoles, int($c->request->params->{userRoles}));
		}
	}
	
	#
	# Create transaction to save data
	#
	my $data = undef;
	$data->{id}				= $c->request->params->{id} || undef;
	$data->{username}		= $c->request->params->{username};
	$data->{active}			= $c->request->params->{active} || 0;
	$data->{email_address}	= $c->request->params->{email} || "";
	$data->{first_name}		= $c->request->params->{first_name} || "";
	$data->{last_name}		= $c->request->params->{last_name} || "";
	
	if ( ! defined($data->{id}) && defined($data->{username}) )
	{
		my $count = $c->model('CMDBv1::User')->search({ username => $data->{username}})->count;
		if ( $count > 0 ) 
		{
			$c->response->body("Username already in use");
			return;
		}
	}
	
	
	$transaction = sub {
		$user = $c->model('CMDBv1::User')->update_or_create($data);
		if ( ! $user->in_storage ) 
		{
			$user->insert;
			$c->log->debug("New user id:" . $user->id);
		} else {
			$user_id = $c->request->params->{id};
			$c->log->info("Updated user $user_id");
		}
		$user_id = $user->id;
		
		
		$user = $c->model('CMDBv1::User')->find({ username => $c->request->params->{username} });
		
		
		if ( defined($c->request->params->{newpass1}) && defined($c->request->params->{newpass2}) 
			&& $c->request->params->{newpass1} eq $c->request->params->{newpass2}
		) { 
			$user->password($c->request->params->{newpass1});
			$user->update;
		} else {
			$c->log->info("Password not updated");
		}
		
	};
	
	$c->model('CMDBv1')->txn_do($transaction);
	
	#
	# Create transaction to handle user roles
	#
	$transaction = sub {
		
		$rs = $c->model('CMDBv1::UserRole')->search(
					{
						user_id => $user_id,
						role_id => { 'NOT IN' => [ @userRoles ]}
					}
				);
		while ( $row = $rs->next ) {
			$row->delete;
		}
		
		foreach my $role ( @userRoles ) {
			my $data = { user_id => $user_id, role_id => $role };
			$c->model('CMDBv1::UserRole')->update_or_create($data);
		} 
	};
	
	# Execute transaction
	$c->model('CMDBv1')->txn_do($transaction);
	
	$c->response->body('User saved');
	
	
	
}

sub delete :Local {
	my($self, $c) = @_;
	my($user_id, $rs);
	$user_id = $c->request->params->{id} || 0;
	
	$rs = $c->model('CMDBv1::User')->find({ id => $user_id });
	
	if ( defined($rs) ) {
		$rs->delete;
	}
	
	$c->response->body('User deleted');
}

sub passwd :Local {
	my($self, $c) = @_;
	my($user, $current, $new1, $new2,$rs);
	
	$current = $c->request->params->{curpass};
	$new1	 = $c->request->params->{newpass1};
	$new2	 = $c->request->params->{newpass2};
	$user    = $c->user->username;
	
	$rs = $c->model('CMDBv1::User')->find({ username => $user });
	
	if ( defined($rs) )
	{
		if ( $rs->check_password($current) )
		{
			if ( $new1 eq $new2 )
			{
				$rs->password($new1);
				$rs->update;
				$c->response->body('Password updated');
			} else {
				$c->response->body("Passwords don\'t match");
			}
		} else {
			$c->response->body('Invalid user password');
		}
	} else {
		$c->response->body('User not found');
		$c->log->error("User $user not found");
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
	
	
	$rs = $c->model("CMDBv1::User")->search(
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
														$row->username,
														$row->first_name,
														$row->last_name,
														$row->active
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
