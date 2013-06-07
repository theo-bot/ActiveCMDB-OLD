package ActiveCMDB::View::Web;
use Moose;
use namespace::autoclean;

extends 'Catalyst::View::TT';

__PACKAGE__->config(
    TEMPLATE_EXTENSION => '.tt',
    render_die => 1,
);

=head1 NAME

ActiveCMDB::View::Web - TT View for ActiveCMDB

=head1 DESCRIPTION

TT View for ActiveCMDB.

=head1 SEE ALSO

L<ActiveCMDB>

=head1 AUTHOR

Theo Bot

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
