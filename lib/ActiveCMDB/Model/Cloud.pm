package ActiveCMDB::Model::Cloud;

use Moose;
use ActiveCMDB::ConfigFactory;
my $config = ActiveCMDB::ConfigFactory->instance();
$config->load('cmdb');
BEGIN { extends 'Catalyst::Model::Riak' };


# From the helper

__PACKAGE__->config(
	host 		=> $config->section("cmdb::cloud::host"),
	ua_timeout	=> $config->section("cmdb::cloud::timeout")
);

=head1 NAME

ActiveCMDB::Model::Cloud - Riak Catalyst model component

=head1 SYNOPSIS

See L<ActiveCMDB>.

=head1 DESCRIPTION

Basho Riak Catalyst model component

=head1 AUTHOR

Theo Bot

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

no Moose;
__PACKAGE__->meta->make_immutable;

1;
