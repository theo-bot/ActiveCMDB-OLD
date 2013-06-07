use utf8;
package ActiveCMDB::Schema::Result::Location;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

ActiveCMDB::Schema::Result::Location

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

=head1 TABLE: C<location>

=cut

__PACKAGE__->table("location");

=head1 ACCESSORS

=head2 location_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 type

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=head2 parent_id

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=head2 name

  data_type: 'varchar'
  is_nullable: 1
  size: 64

=head2 lattitude

  data_type: 'varchar'
  is_nullable: 1
  size: 32

=head2 longitude

  data_type: 'varchar'
  is_nullable: 1
  size: 32

=head2 classification

  data_type: 'varchar'
  is_nullable: 1
  size: 32

=head2 primary_phone

  data_type: 'varchar'
  is_nullable: 1
  size: 32

=head2 primary_contact

  data_type: 'varchar'
  is_nullable: 1
  size: 32

=head2 backup_phone

  data_type: 'varchar'
  is_nullable: 1
  size: 32

=head2 backup_contact

  data_type: 'varchar'
  is_nullable: 1
  size: 32

=head2 details

  data_type: 'varchar'
  is_nullable: 1
  size: 256

=head2 adres1

  data_type: 'varchar'
  is_nullable: 1
  size: 256

=head2 adres2

  data_type: 'varchar'
  is_nullable: 1
  size: 256

=head2 zipcode

  data_type: 'varchar'
  is_nullable: 1
  size: 16

=cut

__PACKAGE__->add_columns(
  "location_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "type",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "parent_id",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "name",
  { data_type => "varchar", is_nullable => 1, size => 64 },
  "lattitude",
  { data_type => "varchar", is_nullable => 1, size => 32 },
  "longitude",
  { data_type => "varchar", is_nullable => 1, size => 32 },
  "classification",
  { data_type => "varchar", is_nullable => 1, size => 32 },
  "primary_phone",
  { data_type => "varchar", is_nullable => 1, size => 32 },
  "primary_contact",
  { data_type => "varchar", is_nullable => 1, size => 32 },
  "backup_phone",
  { data_type => "varchar", is_nullable => 1, size => 32 },
  "backup_contact",
  { data_type => "varchar", is_nullable => 1, size => 32 },
  "details",
  { data_type => "varchar", is_nullable => 1, size => 256 },
  "adres1",
  { data_type => "varchar", is_nullable => 1, size => 256 },
  "adres2",
  { data_type => "varchar", is_nullable => 1, size => 256 },
  "zipcode",
  { data_type => "varchar", is_nullable => 1, size => 16 },
);

=head1 PRIMARY KEY

=over 4

=item * L</location_id>

=back

=cut

__PACKAGE__->set_primary_key("location_id");


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2012-10-30 14:31:29
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:igbwpRU9fS+2uk8Rg88YVg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
