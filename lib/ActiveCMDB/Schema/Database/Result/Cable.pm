use utf8;
package ActiveCMDB::Schema::Database::Result::Cable;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

ActiveCMDB::Schema::Database::Result::Cable

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

=head1 TABLE: C<cable>

=cut

__PACKAGE__->table("cable");

=head1 ACCESSORS

=head2 device_id

  data_type: 'integer'
  is_nullable: 0

=head2 cable_id

  data_type: 'varchar'
  is_nullable: 0
  size: 32

=head2 cable_type

  data_type: 'integer'
  is_nullable: 0

=head2 cable_con_a

  data_type: 'integer'
  is_nullable: 1

=head2 cable_con_b

  data_type: 'integer'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "device_id",
  { data_type => "integer", is_nullable => 0 },
  "cable_id",
  { data_type => "varchar", is_nullable => 0, size => 32 },
  "cable_type",
  { data_type => "integer", is_nullable => 0 },
  "cable_con_a",
  { data_type => "integer", is_nullable => 1 },
  "cable_con_b",
  { data_type => "integer", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</device_id>

=back

=cut

__PACKAGE__->set_primary_key("device_id");


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2012-08-17 15:21:52
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:N0e/a1Xh/cj3ipOSDALSLA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
