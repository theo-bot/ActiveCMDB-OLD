use utf8;
package ActiveCMDB::Schema::Database::Result::IpDevice;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

ActiveCMDB::Schema::Database::Result::IpDevice

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

=back

=cut

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 TABLE: C<ip_device>

=cut

__PACKAGE__->table("ip_device");

=head1 ACCESSORS

=head2 device_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 hostname

  data_type: 'varchar'
  is_nullable: 1
  size: 128

=head2 mgtaddress

  data_type: 'varchar'
  is_nullable: 1
  size: 128

=head2 sysobjectid

  data_type: 'varchar'
  is_nullable: 1
  size: 128

=head2 status

  data_type: 'integer'
  is_nullable: 1

=head2 disco

  data_type: 'bigint'
  default_value: 0
  is_nullable: 1

=head2 device_type

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=head2 contract_id

  data_type: 'integer'
  is_nullable: 1

=head2 location_id

  data_type: 'integer'
  is_nullable: 1

=head2 category

  data_type: 'integer'
  is_nullable: 1

=head2 sysuptime

  data_type: 'bigint'
  is_nullable: 1

=head2 sysdescr

  data_type: 'varchar'
  is_nullable: 1
  size: 512

=head2 external_id

  data_type: 'varchar'
  is_nullable: 1
  size: 128

=head2 added

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 iscritical

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 1

=head2 isssh

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 1

=head2 istelnet

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 1

=head2 tftpset

  data_type: 'varchar'
  default_value: 'DEFAULT'
  is_nullable: 1
  size: 32

=cut

__PACKAGE__->add_columns(
  "device_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "hostname",
  { data_type => "varchar", is_nullable => 1, size => 128 },
  "mgtaddress",
  { data_type => "varchar", is_nullable => 1, size => 128 },
  "sysobjectid",
  { data_type => "varchar", is_nullable => 1, size => 128 },
  "status",
  { data_type => "integer", is_nullable => 1 },
  "disco",
  { data_type => "bigint", default_value => 0, is_nullable => 1 },
  "device_type",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "contract_id",
  { data_type => "integer", is_nullable => 1 },
  "location_id",
  { data_type => "integer", is_nullable => 1 },
  "category",
  { data_type => "integer", is_nullable => 1 },
  "sysuptime",
  { data_type => "bigint", is_nullable => 1 },
  "sysdescr",
  { data_type => "varchar", is_nullable => 1, size => 512 },
  "external_id",
  { data_type => "varchar", is_nullable => 1, size => 128 },
  "added",
  {
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
  "iscritical",
  { data_type => "tinyint", default_value => 0, is_nullable => 1 },
  "isssh",
  { data_type => "tinyint", default_value => 0, is_nullable => 1 },
  "istelnet",
  { data_type => "tinyint", default_value => 0, is_nullable => 1 },
  "tftpset",
  {
    data_type => "varchar",
    default_value => "DEFAULT",
    is_nullable => 1,
    size => 32,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</device_id>

=back

=cut

__PACKAGE__->set_primary_key("device_id");

=head1 UNIQUE CONSTRAINTS

=head2 C<mgtaddres>

=over 4

=item * L</mgtaddress>

=back

=cut

__PACKAGE__->add_unique_constraint("mgtaddres", ["mgtaddress"]);

=head1 RELATIONS

=head2 ip_device_entities

Type: has_many

Related object: L<ActiveCMDB::Schema::Database::Result::IpDeviceEntity>

=cut

__PACKAGE__->has_many(
  "ip_device_entities",
  "ActiveCMDB::Schema::Database::Result::IpDeviceEntity",
  { "foreign.device_id" => "self.device_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 ip_device_ints

Type: has_many

Related object: L<ActiveCMDB::Schema::Database::Result::IpDeviceInt>

=cut

__PACKAGE__->has_many(
  "ip_device_ints",
  "ActiveCMDB::Schema::Database::Result::IpDeviceInt",
  { "foreign.device_id" => "self.device_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 ip_device_journals

Type: has_many

Related object: L<ActiveCMDB::Schema::Database::Result::IpDeviceJournal>

=cut

__PACKAGE__->has_many(
  "ip_device_journals",
  "ActiveCMDB::Schema::Database::Result::IpDeviceJournal",
  { "foreign.device_id" => "self.device_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 ip_device_sec

Type: might_have

Related object: L<ActiveCMDB::Schema::Database::Result::IpDeviceSec>

=cut

__PACKAGE__->might_have(
  "ip_device_sec",
  "ActiveCMDB::Schema::Database::Result::IpDeviceSec",
  { "foreign.device_id" => "self.device_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 ip_devices_at

Type: has_many

Related object: L<ActiveCMDB::Schema::Database::Result::IpDeviceAt>

=cut

__PACKAGE__->has_many(
  "ip_devices_at",
  "ActiveCMDB::Schema::Database::Result::IpDeviceAt",
  { "foreign.device_id" => "self.device_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2012-08-17 15:21:52
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:CVZQYk3jp6ziELN9ylgzqQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
