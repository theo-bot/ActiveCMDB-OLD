use utf8;
package ActiveCMDB::Schema::Result::DistModel;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

ActiveCMDB::Schema::Result::DistModel

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

=head1 TABLE: C<dist_model>

=cut

__PACKAGE__->table("dist_model");

=head1 ACCESSORS

=head2 model_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 model_descr

  data_type: 'varchar'
  is_nullable: 1
  size: 64

=head2 model_active

  data_type: 'tinyint'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "model_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "model_descr",
  { data_type => "varchar", is_nullable => 1, size => 64 },
  "model_active",
  { data_type => "tinyint", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</model_id>

=back

=cut

__PACKAGE__->set_primary_key("model_id");

=head1 UNIQUE CONSTRAINTS

=head2 C<model_descr_UNIQUE>

=over 4

=item * L</model_descr>

=back

=cut

__PACKAGE__->add_unique_constraint("model_descr_UNIQUE", ["model_descr"]);

=head1 RELATIONS

=head2 dist_rules

Type: has_many

Related object: L<ActiveCMDB::Schema::Result::DistRule>

=cut

__PACKAGE__->has_many(
  "dist_rules",
  "ActiveCMDB::Schema::Result::DistRule",
  { "foreign.model_id" => "self.model_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2012-10-30 14:31:29
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:b3mSUOrVhcAP96AGpNDgAw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
