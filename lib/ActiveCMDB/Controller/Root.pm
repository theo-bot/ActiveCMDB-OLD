package ActiveCMDB::Controller::Root;

=begin nd

    Script: ActiveCMDB::Controller::Root.pm
    ___________________________________________________________________________

    Version 1.0

    Copyright (C) 2011-2015 Theo Bot

    http://www.activecmdb.org


    Topic: Purpose

    Cayalyst Root Controller

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

BEGIN { extends 'Catalyst::Controller' }

#
# Sets the actions in this controller to be registered with no prefix
# so they function identically to actions created in MyApp.pm
#
__PACKAGE__->config(namespace => '');


=head2 index

The root page (/)

=cut

sub index :Private {
    my ( $self, $c ) = @_;

#    # Hello World
    $c->stash->{template} = 'index.tt';
}

sub noauth :Local {
	my($self, $c) = @_;
	
	$c->stash->{template} = 'un_authorized.tt';
}
=head2 default

Standard 404 error page

=cut

sub default :Private {
	my($self, $c) = @_;
	$c->log->warn("Request: " . $c->request->path );
	$c->response->status(404);
	$c->stash->{template} = 'not_found.tt';
}

=head2 end

Attempt to render a view, if needed.

=cut

sub end : ActionClass('RenderView') {}


sub auto : Private {
	my($self, $c) = @_;
	
	if ($c->controller eq $c->controller('Login')) {
		return 1;
	}
	
	if ( !$c->user_exists ) {
		$c->log->debug('***Root::auto User not found, forwarding to /login');
		
		$c->response->redirect($c->uri_for('/login'));
		
		return 0;
	}
	
	$c->log->info("User found continue processing");
	return 1;
}

__PACKAGE__->meta->make_immutable;

1;
