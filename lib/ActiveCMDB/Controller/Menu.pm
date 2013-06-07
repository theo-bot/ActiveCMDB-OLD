package ActiveCMDB::Controller::Menu;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

ActiveCMDB::Controller::Menu - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->stash->{template} = 'menu.tt';
}

sub header :Local {
	my($self, $c) = @_;
	
	$c->stash->{template} = 'header.tt';
}

sub empty :Local {
	my($self, $c) = @_;
	$c->response->status(200);
	$c->response->body('');
}
=head1 AUTHOR

Theo Bot

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
