package ActiveCMDB::Model::Riak;
use Moose;
use namespace::autoclean;

extends 'Catalyst::Model::Riak';

__PACKAGE__->config(
	host => 'http://192.168.178.20:8098',
	ua_timeout => 900
);

=head1 NAME

ActiveCMDB::Model::Riak - Catalyst Model

=head1 DESCRIPTION

Catalyst Model.

=head1 AUTHOR

Theo Bot

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
