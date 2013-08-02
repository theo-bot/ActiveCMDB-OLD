use utf8;
package ActiveCMDB::Schema::Result::IpDeviceInt;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

ActiveCMDB::Schema::Result::IpDeviceInt

=cut

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=item * L<DBIx::Class::TimeStamp>

=item * L<DBIx::Class::EncodedColumn>

=back

=cut

__PACKAGE__->load_components("InflateColumn::DateTime", "TimeStamp", "EncodedColumn");

=head1 TABLE: C<ip_device_int>

=cut

__PACKAGE__->table("ip_device_int");

=head1 ACCESSORS

=head2 device_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 ifindex

  data_type: 'integer'
  is_nullable: 0

=head2 iftype

  data_type: 'integer'
  is_nullable: 1

=head2 ifdescr

  data_type: 'varchar'
  is_nullable: 1
  size: 64

=head2 ifname

  data_type: 'varchar'
  is_nullable: 1
  size: 64

=head2 ifspeed

  data_type: 'bigint'
  is_nullable: 1

=head2 ifadminstatus

  data_type: 'tinyint'
  is_nullable: 1

=head2 ifoperstatus

  data_type: 'tinyint'
  is_nullable: 1

=head2 ifalias

  data_type: 'varchar'
  is_nullable: 1
  size: 128

=head2 cable_id

  data_type: 'integer'
  default_value: 0
  is_nullable: 1

=head2 ifphysaddress

  data_type: 'varchar'
  is_nullable: 1
  size: 32

=head2 ifhighspeed

  data_type: 'bigint'
  default_value: 0
  is_nullable: 1

=head2 iflastchange

  data_type: 'bigint'
  default_value: 0
  is_nullable: 1

=head2 istrunk

  data_type: 'smallint'
  default_value: 0
  is_nullable: 1

=head2 disco

  data_type: 'bigint'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "device_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "ifindex",
  { data_type => "integer", is_nullable => 0 },
  "iftype",
  { data_type => "integer", is_nullable => 1 },
  "ifdescr",
  { data_type => "varchar", is_nullable => 1, size => 64 },
  "ifname",
  { data_type => "varchar", is_nullable => 1, size => 64 },
  "ifspeed",
  { data_type => "bigint", is_nullable => 1 },
  "ifadminstatus",
  { data_type => "tinyint", is_nullable => 1 },
  "ifoperstatus",
  { data_type => "tinyint", is_nullable => 1 },
  "ifalias",
  { data_type => "varchar", is_nullable => 1, size => 128 },
  "cable_id",
  { data_type => "integer", default_value => 0, is_nullable => 1 },
  "ifphysaddress",
  { data_type => "varchar", is_nullable => 1, size => 32 },
  "ifhighspeed",
  { data_type => "bigint", default_value => 0, is_nullable => 1 },
  "iflastchange",
  { data_type => "bigint", default_value => 0, is_nullable => 1 },
  "istrunk",
  { data_type => "smallint", default_value => 0, is_nullable => 1 },
  "disco",
  { data_type => "bigint", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</device_id>

=item * L</ifindex>

=back

=cut

__PACKAGE__->set_primary_key("device_id", "ifindex");

=head1 RELATIONS

=head2 device

Type: belongs_to

Related object: L<ActiveCMDB::Schema::Result::IpDevice>

=cut

__PACKAGE__->belongs_to(
  "device",
  "ActiveCMDB::Schema::Result::IpDevice",
  { device_id => "device_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 ip_device_nets

Type: has_many

Related object: L<ActiveCMDB::Schema::Result::IpDeviceNet>

=cut

__PACKAGE__->has_many(
  "ip_device_nets",
  "ActiveCMDB::Schema::Result::IpDeviceNet",
  {
    "foreign.device_id"      => "self.device_id",
    "foreign.ipadentifindex" => "self.ifindex",
  },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 ip_device_vlan

Type: might_have

Related object: L<ActiveCMDB::Schema::Result::IpDeviceIntVlan>

=cut

__PACKAGE__->might_have(
  "ip_device_vlan",
  "ActiveCMDB::Schema::Result::IpDeviceIntVlan",
  {
    "foreign.device_id" => "self.device_id",
    "foreign.ifindex"   => "self.ifindex",
  },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 ip_device_vrfs

Type: has_many

Related object: L<ActiveCMDB::Schema::Result::IpDeviceVrf>

=cut

__PACKAGE__->has_many(
  "ip_device_vrfs",
  "ActiveCMDB::Schema::Result::IpDeviceVrf",
  {
    "foreign.device_id" => "self.device_id",
    "foreign.ifindex"   => "self.ifindex",
  },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2012-10-30 14:31:29
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:J0tWhngFw14J62NayRj5qg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
