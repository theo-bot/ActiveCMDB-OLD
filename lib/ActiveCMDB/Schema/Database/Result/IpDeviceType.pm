use utf8;
package ActiveCMDB::Schema::Database::Result::IpDeviceType;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

ActiveCMDB::Schema::Database::Result::IpDeviceType - Device types

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

=head1 TABLE: C<ip_device_type>

=cut

__PACKAGE__->table("ip_device_type");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 descr

  data_type: 'varchar'
  is_nullable: 1
  size: 32

=head2 sysobjectid

  data_type: 'varchar'
  is_nullable: 1
  size: 128

=head2 disco_model

  data_type: 'integer'
  is_nullable: 1

=head2 active

  data_type: 'tinyint'
  is_nullable: 1

=head2 vendor_id

  data_type: 'integer'
  is_nullable: 1

=head2 networktype

  data_type: 'integer'
  default_value: 1
  is_nullable: 0

=head2 class

  data_type: 'integer'
  default_value: 1
  is_nullable: 1

=head2 image

  data_type: 'varchar'
  is_nullable: 1
  size: 256

=head2 disco_scheme

  data_type: 'integer'
  is_nullable: 1

=head2 objectclass

  data_type: 'varchar'
  is_nullable: 1
  size: 256

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "descr",
  { data_type => "varchar", is_nullable => 1, size => 32 },
  "sysobjectid",
  { data_type => "varchar", is_nullable => 1, size => 128 },
  "disco_model",
  { data_type => "integer", is_nullable => 1 },
  "active",
  { data_type => "tinyint", is_nullable => 1 },
  "vendor_id",
  { data_type => "integer", is_nullable => 1 },
  "networktype",
  { data_type => "integer", default_value => 1, is_nullable => 0 },
  "class",
  { data_type => "integer", default_value => 1, is_nullable => 1 },
  "image",
  { data_type => "varchar", is_nullable => 1, size => 256 },
  "disco_scheme",
  { data_type => "integer", is_nullable => 1 },
  "objectclass",
  { data_type => "varchar", is_nullable => 1, size => 256 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<sysObjectID_UNIQUE>

=over 4

=item * L</sysobjectid>

=back

=cut

__PACKAGE__->add_unique_constraint("sysObjectID_UNIQUE", ["sysobjectid"]);


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2012-08-17 15:21:52
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:6dwNGOCitoXCMFQ5kyzWlg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
