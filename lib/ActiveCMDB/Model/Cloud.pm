package ActiveCMDB::Model::Cloud;

=begin nd

    Script: ActiveCMDB::Model::Cloud.pm
    ___________________________________________________________________________

    Version 1.0

    Copyright (C) 2012-2013 Theo Bot

    http://www.activecmdb.org


    Topic: Purpose

    Catalyst Model for Catalyst::Model::Riak

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

#########################################################################
# Initialize  modules
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
