use utf8;
package ActiveCMDB::Schema::Database::Result::IpDeviceNet;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

ActiveCMDB::Schema::Database::Result::IpDeviceNet

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

=head1 TABLE: C<ip_device_net>

=cut

__PACKAGE__->table("ip_device_net");

=head1 ACCESSORS

=head2 device_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 ipadentifindex

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 type

  data_type: 'integer'
  is_nullable: 1

=head2 ipadentaddr

  data_type: 'varchar'
  is_nullable: 0
  size: 256

=head2 ipadentnetmask

  data_type: 'varchar'
  is_nullable: 1
  size: 256

=head2 last_update

  data_type: 'integer'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "device_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "ipadentifindex",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "type",
  { data_type => "integer", is_nullable => 1 },
  "ipadentaddr",
  { data_type => "varchar", is_nullable => 0, size => 256 },
  "ipadentnetmask",
  { data_type => "varchar", is_nullable => 1, size => 256 },
  "last_update",
  { data_type => "integer", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</device_id>

=item * L</ipadentaddr>

=back

=cut

__PACKAGE__->set_primary_key("device_id", "ipadentaddr");

=head1 RELATIONS

=head2 ip_device_int

Type: belongs_to

Related object: L<ActiveCMDB::Schema::Database::Result::IpDeviceInt>

=cut

__PACKAGE__->belongs_to(
  "ip_device_int",
  "ActiveCMDB::Schema::Database::Result::IpDeviceInt",
  { device_id => "device_id", ifindex => "ipadentifindex" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2012-08-17 15:21:52
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:11t/CkA63ESP3d4BG1982g


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
