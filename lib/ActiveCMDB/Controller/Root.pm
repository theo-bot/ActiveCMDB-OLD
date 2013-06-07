package ActiveCMDB::Controller::Root;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller' }

#
# Sets the actions in this controller to be registered with no prefix
# so they function identically to actions created in MyApp.pm
#
__PACKAGE__->config(namespace => '');

=head1 NAME

ActiveCMDB::Controller::Root - Root Controller for ActiveCMDB

=head1 DESCRIPTION

[enter your description here]

=head1 METHODS

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

=head1 AUTHOR

Theo Bot

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

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
