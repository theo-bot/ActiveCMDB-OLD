package ActiveCMDB::Object::User;


=head1 ActiveCMDB::Object::User.pm
    ___________________________________________________________________________

=head1 Version 1.0

=head1 Copyright
    Copyright (C) 2011-2015 Theo Bot

    http://www.activecmdb.org


=head1 Description

    ActiveCMDB::Object::User class definition

=head1 License

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
use Moose::Util::TypeConstraints;
use Try::Tiny;
use Data::Dumper;
use DateTime;
use Logger;
use ActiveCMDB::Common::Constants;
use ActiveCMDB::Common::Roles;

has 'id'			=> (is => 'rw', isa => 'Int');
has 'username'		=> (is => 'rw', isa => 'Str');
has 'active'		=> (is => 'rw', isa => 'Int', default => 0);
has 'email_address'	=> (is => 'rw', isa => 'Maybe[Str]');
has 'first_name'	=> (is => 'rw', isa => 'Maybe[Str]');
has 'last_name'		=> (is => 'rw', isa => 'Maybe[Str]');
has 'password'		=> (is => 'rw', isa => 'Str');

my %map = (
	id				=> 'id',
	username		=> 'username',
	active			=> 'active',
	email_address	=> 'email_address',
	first_name		=> 'first_name',
	last_name		=> 'last_name',
	password		=> 'password'
);

# Schema
has 'schema'		=> (
	is => 'rw', 
	isa => 'Object', 
	default => sub { ActiveCMDB::Model::CMDBv1->instance() } 
);
with 'ActiveCMDB::Object::Methods';

sub get_data
{
	my($self) = @_;
	
	if ( defined($self->username) || defined($self->id) ) {
		my $query = { username => $self->username };
		if ( !defined($self->username) && defined($self->id) ) {
			$query = { id => $self->id };
		}
		my $row = $self->schema->resultset("User")->find( $query );
		if ( defined($row) ) {
			foreach my $k (keys %map)
			{
				$self->$k($row->$k);
			}
			$self->password($row->password);
		} else {
			Logger->warn("Row not found");
		}
	} else {
		Logger->warn("Username not set");
	}
}

sub save
{
	my($self,@userRoles) = @_;
	my $result=0;
	Logger->info("Saving user ");
	if ( defined($self->username) )
	{
		my $data = $self->to_hashref(\%map);
		Logger->debug(Dumper($data));
		try {
			
			my $row = $self->schema->resultset("User")->update_or_create($data);
			if ( !defined($self->id) && defined($row->id) ) {
				$self->id($row->id);
			} 
			
			#
			# Create transaction to handle user roles
			#
			my @role_ids = ();
			foreach my $role (@userRoles)
			{
				if ( $role  =~ /^\d+$/ )
				{
					push(@role_ids, $role);
				} else {
					my $r = getRoleByName($role);
					push(@role_ids, $r) if (defined($r));
				}
			}
			
			my $transaction = sub {
		
				my $rs = $self->schema->resultset('UserRole')->search(
						{
							user_id => $self->id,
							role_id => { 'NOT IN' => [ @role_ids ]}
						}
					);
				while ( my $row = $rs->next ) {
					$row->delete;
				}
		
				foreach my $role ( @role_ids ) {
					my $data = { user_id => $self->id, role_id => $role };
					$self->schema->resultset('UserRole')->update_or_create($data);
				} 
			};
	
			# Execute transaction
			$self->schema->txn_do($transaction);
			$result = 1;
		} catch {
				Logger->warn("Failed to add/update user.");
				Logger->debug($_);
		};	
	} else {
		Logger->warn("Username not set");
	}
	
	return $result;
}

sub delete
{
	my($self) = @_;
	
	if ( defined($self->id) )
	{
		my $row = $self->schema->resultset("User")->find({ id => $self->id });
		if ( defined($row) ) {
			$row->delete();
		}
	}
}

sub passwd
{
	my($self, $current, $new1, $new2) = @_;
	my $res = undef;
	my $row = $self->schema->resultset('User')->find({ username => $self->username });
	
	if ( defined($row) )
	{
		if ( $row->check_password($current) )
		{
			if ( $new1 eq $new2 )
			{
				$row->password($new1);
				$row->update;
				$res = 'Password updated';
			} else {
				$res = "Passwords don\'t match";
			}
		} else {
			$res = 'Invalid user password';
		}
	} else {
		$res = 'User not found';
		Logger->error("User $self->username not found");
	}
}

sub has_role
{
	my($self, $role) = @_;
	
	if ( defined($role) && defined($self->username) )
	{
		my $rs = $self->schema->resultset("User")->search(
				{
					username	=> $self->username,
					'role.role'	=> $role
				},
				{
					join		=> { map_user_role =>  'role' },
					+select		=> ['username','role.role'],
					+as			=> ['username','role_name']
				}	
		);
		
		if ( defined($rs) && $rs->count() > 0 ) {
			return true;
		}
	}
}

sub exist
{
	my($self) = @_;
	
	my $count = $self->schema->resultset('User')->search({ username => $self->username})->count;
	Logger->debug("User count $count");
	return $count;
}

sub roles
{
	my($self) = @_;
	
	my @assigned = ();
	my $rs = $self->schema->resultset('UserRole')->search({ user_id => $self->id });
	while ( my $row = $rs->next )
	{
		push(@assigned, $row->role->role );
	}
	
	return @assigned;
}

sub assigned_roles
{
	my($self) = @_;
	
	my @assigned = ();
	my $rs = $self->schema->resultset('UserRole')->search({ user_id => $self->id });
	while ( my $row = $rs->next )
	{
		push(@assigned, { id => $row->role_id, role => $row->role->role });
	}
	
	return @assigned;
}

sub available_roles
{
	my($self) = @_;
	
	my @available = ();
	my $subselect = $self->schema->resultset('UserRole')->search(
		{
			user_id => $self->id
		},
		{
			columns => qw/role_id/
		}
	);
	
	my $select = $self->schema->resultset('Role')->search(
		{
			id => { -not_in => $subselect->get_column('role_id')->as_query }
		}
	);
	
	while ( my $row = $select->next )
	{
		push(@available, { id => $row->id, role => $row->role });
	}
	
	return @available;
}

1;