use utf8;
package ActiveCMDB::Schema::Result::DiscoScheme;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

ActiveCMDB::Schema::Result::DiscoScheme

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

=head1 TABLE: C<disco_schemes>

=cut

__PACKAGE__->table("disco_schemes");

=head1 ACCESSORS

=head2 scheme_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 name

  data_type: 'varchar'
  is_nullable: 1
  size: 32

=head2 active

  data_type: 'tinyint'
  default_value: 1
  is_nullable: 0

=head2 block1

  data_type: 'varchar'
  is_nullable: 1
  size: 32

=head2 block2

  data_type: 'varchar'
  is_nullable: 1
  size: 32

=cut

__PACKAGE__->add_columns(
  "scheme_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "name",
  { data_type => "varchar", is_nullable => 1, size => 32 },
  "active",
  { data_type => "tinyint", default_value => 1, is_nullable => 0 },
  "block1",
  { data_type => "varchar", is_nullable => 1, size => 32 },
  "block2",
  { data_type => "varchar", is_nullable => 1, size => 32 },
);

=head1 PRIMARY KEY

=over 4

=item * L</scheme_id>

=back

=cut

__PACKAGE__->set_primary_key("scheme_id");


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2012-10-30 14:31:29
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:oViUXhdGAkB9nlCjgKJx8w


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
