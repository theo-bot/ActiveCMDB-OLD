use utf8;
package ActiveCMDB::Schema::Result::IpDeviceVlan;

=head1 MODULE - ActiveCMDB::Schema::Result::IpDeviceVlan
    ___________________________________________________________________________

=head1 VERSION

    Version 1.0

=head1 COPYRIGHT

    Copyright (C) 2011-2015 Theo Bot

    http://www.activecmdb.org


=head1 DESCRIPTION

    Schema file for ip_device_vlan table

=head1 LICENSE

    This program is free software; you can redistribute it and/or
    modify it under the terms of the GNU General Public License
    as published by the Free Software Foundation; either version 2
    of the License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

=cut

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';

=head1 TABLE: C<ip_device_vlan>

=cut

__PACKAGE__->table("ip_device_vlan");

__PACKAGE__->add_columns(
  "device_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "vlan_id",
  { data_type => "integer", is_nullable => 0 },
  "disco",
  { data_type => "integer", is_nullable => 1 },
  "name",
  { data_type => "varchar", size => 128, is_nullable => 1},
  "status",
  { data_type => "varchar", size => 32, is_nullable => 1},
);

__PACKAGE__->set_primary_key("device_id", "vlan_id");

=head1 RELATIONS

=head2 ip_device_int

Type: belongs_to

Related object: L<ActiveCMDB::Schema::Result::IpDeviceInt>

=cut

__PACKAGE__->belongs_to(
  "ip_device",
  "ActiveCMDB::Schema::Result::IpDevice",
  { device_id => "device_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

__PACKAGE__->meta->make_immutable;
1;