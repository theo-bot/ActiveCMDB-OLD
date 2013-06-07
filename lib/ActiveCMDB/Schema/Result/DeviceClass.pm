use utf8;
package ActiveCMDB::Schema::Result::DeviceClass;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

ActiveCMDB::Schema::Result::DeviceClass

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

=head1 TABLE: C<device_class>

=cut

__PACKAGE__->table("device_class");

=head1 ACCESSORS

=head2 class_id

  data_type: 'integer'
  is_nullable: 0

=head2 name

  data_type: 'varchar'
  is_nullable: 1
  size: 16

=head2 superclass

  data_type: 'varchar'
  is_nullable: 1
  size: 16

=head2 enabled

  data_type: 'tinyint'
  is_nullable: 1

=head2 revision

  data_type: 'integer'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "class_id",
  { data_type => "integer", is_nullable => 0 },
  "name",
  { data_type => "varchar", is_nullable => 1, size => 16 },
  "superclass",
  { data_type => "varchar", is_nullable => 1, size => 16 },
  "enabled",
  { data_type => "tinyint", is_nullable => 1 },
  "revision",
  { data_type => "integer", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</class_id>

=back

=cut

__PACKAGE__->set_primary_key("class_id");


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2012-10-30 14:31:29
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:+WK2lAoaHdl6Ox1wHCe9uA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
