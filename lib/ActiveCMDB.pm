package ActiveCMDB;

=begin nd

    Script: AvtiveCMDB::ActiveCMDB.pm
    ___________________________________________________________________________

    Version 1.0

    Copyright (C) 2011-2015 Theo Bot

    http://www.activecmdb.org


    Topic: Purpose

    Common System Library

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

use Catalyst::Runtime 5.80;

# Set flags and add plugins for the application.
#
# Note that ORDERING IS IMPORTANT here as plugins are initialized in order,
# therefore you almost certainly want to keep ConfigLoader at the head of the
# list if you're using it.
#
#         -Debug: activates the debug mode for very useful log messages
#   ConfigLoader: will load the configuration from a Config::General file in the
#                 application's home directory
# Static::Simple: will serve static files from the application's root
#                 directory

use Catalyst qw/
    -Debug
    ConfigLoader
    Static::Simple
    Authentication
	Authorization::Roles
	Session
	Session::State::Cookie
	Session::Store::FastMmap
/;

extends 'Catalyst';

our $VERSION = '0.01';

# Configure the application.
#
# Note that settings in activecmdb.conf (or other external
# configuration file that you set up manually) take precedence
# over this when using ConfigLoader. Thus configuration
# details given here can function as a default configuration,
# with an external configuration file acting as an override for
# local deployment.

__PACKAGE__->config(
    name => 'ActiveCMDB',
    # Disable deprecated behavior needed by old applications
    disable_component_resolution_regex_fallback => 1,
    enable_catalyst_header	=> 1, # Send X-Catalyst header
    session 				=> { 
    								flash_to_stash => 1,
    								expires => 900
    							 },
    'View::JSON'			=> { expose_stash => 'json' },
);

__PACKAGE__->config->{'Plugin::Authentication'} = {
		default => {
			class			=> 'SimpleDB',
			user_model		=> 'CMDBv1::User',
			password_type	=> 'self_check',
		}
};

# Start the application
__PACKAGE__->setup();


=head1 NAME

ActiveCMDB - Catalyst based application

=head1 SYNOPSIS

    script/activecmdb_server.pl

=head1 DESCRIPTION

[enter your description here]

=head1 SEE ALSO

L<ActiveCMDB::Controller::Root>, L<Catalyst>

=head1 AUTHOR

Theo Bot

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
