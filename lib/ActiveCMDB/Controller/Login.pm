package ActiveCMDB::Controller::Login;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

ActiveCMDB::Controller::Login - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

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


=head1 AUTHOR

Theo Bot

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
