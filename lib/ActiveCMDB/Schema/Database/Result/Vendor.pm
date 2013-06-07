use utf8;
package ActiveCMDB::Schema::Database::Result::Vendor;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

ActiveCMDB::Schema::Database::Result::Vendor

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

=head1 TABLE: C<vendor>

=cut

__PACKAGE__->table("vendor");

=head1 ACCESSORS

=head2 vendor_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 vendor_name

  data_type: 'varchar'
  is_nullable: 1
  size: 128

=head2 vendor_phone

  data_type: 'varchar'
  is_nullable: 1
  size: 32

=head2 vendor_support_phone

  data_type: 'varchar'
  is_nullable: 1
  size: 32

=head2 vendor_support_email

  data_type: 'varchar'
  is_nullable: 1
  size: 256

=head2 vendor_support_www

  data_type: 'varchar'
  is_nullable: 1
  size: 256

=head2 vendor_enterprises

  data_type: 'varchar'
  is_nullable: 1
  size: 128

=head2 vendor_details

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "vendor_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "vendor_name",
  { data_type => "varchar", is_nullable => 1, size => 128 },
  "vendor_phone",
  { data_type => "varchar", is_nullable => 1, size => 32 },
  "vendor_support_phone",
  { data_type => "varchar", is_nullable => 1, size => 32 },
  "vendor_support_email",
  { data_type => "varchar", is_nullable => 1, size => 256 },
  "vendor_support_www",
  { data_type => "varchar", is_nullable => 1, size => 256 },
  "vendor_enterprises",
  { data_type => "varchar", is_nullable => 1, size => 128 },
  "vendor_details",
  { data_type => "text", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</vendor_id>

=back

=cut

__PACKAGE__->set_primary_key("vendor_id");


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2012-08-17 15:21:52
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:9csMEkBnR8GDUA6+Hoplpg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
