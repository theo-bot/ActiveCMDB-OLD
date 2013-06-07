use utf8;
package ActiveCMDB::Schema::Result::IpDeviceSec;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

ActiveCMDB::Schema::Result::IpDeviceSec

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

=head1 TABLE: C<ip_device_sec>

=cut

__PACKAGE__->table("ip_device_sec");

=head1 ACCESSORS

=head2 device_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 telnet_user

  data_type: 'varchar'
  is_nullable: 1
  size: 32

=head2 telnet_pwd

  data_type: 'varchar'
  is_nullable: 1
  size: 16

=head2 snmpv

  data_type: 'integer'
  default_value: 1
  is_nullable: 1

=head2 snmp_ro

  data_type: 'varchar'
  is_nullable: 1
  size: 32

=head2 snmp_rw

  data_type: 'varchar'
  is_nullable: 1
  size: 32

=head2 snmpv3_user

  data_type: 'varchar'
  is_nullable: 1
  size: 16

=head2 snmpv3_pass1

  data_type: 'varchar'
  is_nullable: 1
  size: 64

=head2 snmpv3_pass2

  data_type: 'varchar'
  is_nullable: 1
  size: 64

=head2 snmpv3_proto1

  data_type: 'varchar'
  is_nullable: 1
  size: 8

=head2 snmpv3_proto2

  data_type: 'varchar'
  is_nullable: 1
  size: 8

=cut

__PACKAGE__->add_columns(
  "device_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "telnet_user",
  { data_type => "varchar", is_nullable => 1, size => 32 },
  "telnet_pwd",
  { data_type => "varchar", is_nullable => 1, size => 16 },
  "snmpv",
  { data_type => "integer", default_value => 1, is_nullable => 1 },
  "snmp_ro",
  { data_type => "varchar", is_nullable => 1, size => 32 },
  "snmp_rw",
  { data_type => "varchar", is_nullable => 1, size => 32 },
  "snmpv3_user",
  { data_type => "varchar", is_nullable => 1, size => 16 },
  "snmpv3_pass1",
  { data_type => "varchar", is_nullable => 1, size => 64 },
  "snmpv3_pass2",
  { data_type => "varchar", is_nullable => 1, size => 64 },
  "snmpv3_proto1",
  { data_type => "varchar", is_nullable => 1, size => 8 },
  "snmpv3_proto2",
  { data_type => "varchar", is_nullable => 1, size => 8 },
);

=head1 PRIMARY KEY

=over 4

=item * L</device_id>

=back

=cut

__PACKAGE__->set_primary_key("device_id");

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


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2012-10-30 14:31:29
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:wC0jeFsLxYc9zD9ToTg8pg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
