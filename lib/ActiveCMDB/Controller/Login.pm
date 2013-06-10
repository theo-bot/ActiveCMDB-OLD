package ActiveCMDB::Controller::Login;

=begin nd

    Script: ActiveCMDB::Controller::Login.pm
    ___________________________________________________________________________

    Version 1.0

    Copyright (C) 2012-2013 Theo Bot

    http://www.activecmdb.org


    Topic: Purpose

    Catalyst Controller for managing logins

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

BEGIN { extends 'Catalyst::Controller'; }

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    my $username = $c->request->params->{username} || "";
    my $password = $c->request->params->{password} || "";
    
    if ( $username && $password) {
    	if ( $c->authenticate({ username => $username,
    							password => $password
    	})) {
    		# If successful, then use application
    		$c->log->info("User authenticated continue processing");
    		$c->response->redirect($c->uri_for($c->controller('Root')->action_for('index')));
    		return;
    	} else {
    		$c->log->info("Bad username or password");
    		$c->stash->{error_msg} = "Bad username or password.";
    	}
    }
    
    $c->stash->{template} = "users/login.tt";
}

__PACKAGE__->meta->make_immutable;

1;
