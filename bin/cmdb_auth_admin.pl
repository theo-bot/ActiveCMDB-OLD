#!/usr/bin/env perl

use v5.16.0;
use Getopt::Long;
use Pod::Usage;
use ActiveCMDB::Common::Users;
use ActiveCMDB::Common::Roles;
use ActiveCMDB::Object::User;
use Term::ReadKey;
use Data::Dumper;

my($list,$users,$roles,$add,$delete,$help,$enable,$disable);
my($username,$passwd,$first,$last,$email,$active);
my @roles = ();

GetOptions(
	"help"			=> \$help,
	"users"			=> \$users,
	"roles"			=> \$roles,
	"role=s"		=> \@roles,
	"list"			=> \$list,
	"add"			=> \$add,
	"delete"		=> \$delete,
	"u=s"			=> \$username,
	"p=s"			=> \$passwd,
	"f=s"			=> \$first,
	"l=s"			=> \$last,
	"e=s"			=> \$email,
	"a|active"		=> \$active,
) or pod2usage(1);

pod2usage(-verbose => 99, -sections => [ qw/NAME SYSOPSIS DESCRIPTION COPYRIGHT/ ]) if $help;

#
# Add a user
#
if ( $add && $username )
{
	my $exitcode = 1;
	my $user = ActiveCMDB::Object::User->new(username => $username);
	if ( !$user->exist )
	{
		if ( !defined($passwd) ) {
			print "User password :";
			ReadMode 2;
			chomp($passwd = <STDIN> );
			ReadMode 0;
		}
		$user->password($passwd);
		$user->email_address($email) if defined($email);
		$user->first_name($first) if defined($first);
		$user->last_name($last) if defined($last);
		$user->active($active) if defined($active);
		$user->email_address($email) if defined($email);
		if ( $user->save(@roles) ) 
		{
			print STDOUT "User added\n";
			Logger->info("User $username added by " . getpwuid($<));
			$exitcode = 0;
		} else {
			print STDERR "ERROR: Failed to add user, please check the log\n";
		}
	} else {
		Logger->warn("User $username exists, cannot be added");
		print STDERR "ERROR: User exists\n";
	}
	exit $exitcode;
}

#
# Delete a user
#
if ( $delete && $username )
{
	my $user = ActiveCMDB::Object::User->new(username => $username);
	my $exitcode = 1;
	if ( $user->exist )
	{
		$user->get_data();
		if ( $user->delete() )
		{
			print STDOUT "User $username deleted\n";
			Logger->info("User $username deleted by " . getpwuid($<));
			$exitcode = 0;
		} else {
			print STDERR "ERROR: Cannot delete user, please check the log."
		}
	} else {
		print STDERR "No such user\n";
	}
	exit $exitcode;
}


#
# Add a new role
#
if ( $add && scalar(@roles) == 1 )
{
	my $exitcode = 1;
	my $role = ActiveCMDB::Object::UserRole->new(role => $roles[0]);
	if ( !$role->exist )
	{
		$role->save();
		Logger->info("Role $roles[0] added by " . getpwuid($<));
	} else {
		Logger->warn("Role $roles[0] exists, cannot be added");
		print STDERR "ERROR: Role exists\n";
	}
}


#
# List users
#
if ( $list && $users ) {
	cmdb_list_users();
	exit 0;
}

#
# List roles
#
if ( $list && $roles ) {
	cmdb_list_roles();
	exit 0;
}

__END__

=head1 NAME

cmdb_auth_admin.pl - Manage user security

=head1 SYNOPSIS

sample [options] [file ...]

 Options:
  --help brief help message
  --export export users and or roles
  --add add new user or role
  
=head1 OPTIONS

=over 8

=item B<-help>

Print a brief help message and exits.

=item B<-export>

Export all values in so the can be imported.

=item B<-add>

Add an snmp mib translation

=head1 DESCRIPTION

B<This program> will read the given input file(s) and do something
useful with the contents thereof.

=head1 COPYRIGHT

Copyright (C) 2011-2015 Theo Bot

http://www.activecmdb.org

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

=back

=cut