use utf8;
package ActiveCMDB::Schema::Result::DistRule;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

ActiveCMDB::Schema::Result::DistRule

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

=head1 TABLE: C<dist_rules>

=cut

__PACKAGE__->table("dist_rules");

=head1 ACCESSORS

=head2 rule_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 model_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 rule_order

  data_type: 'integer'
  default_value: 99
  is_nullable: 1

=head2 rule_name

  data_type: 'varchar'
  is_nullable: 1
  size: 45

=head2 rule_active

  data_type: 'tinyint'
  default_value: 1
  is_nullable: 1

=head2 rule_ep

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 vendors

  data_type: 'varchar'
  is_nullable: 1
  size: 1024

=head2 types

  data_type: 'varchar'
  is_nullable: 1
  size: 1024

=head2 hostname

  data_type: 'varchar'
  is_nullable: 1
  size: 1024

=cut

__PACKAGE__->add_columns(
  "rule_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "model_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "rule_order",
  { data_type => "integer", default_value => 99, is_nullable => 1 },
  "rule_name",
  { data_type => "varchar", is_nullable => 1, size => 45 },
  "rule_active",
  { data_type => "tinyint", default_value => 1, is_nullable => 1 },
  "rule_ep",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "vendors",
  { data_type => "varchar", is_nullable => 1, size => 1024 },
  "types",
  { data_type => "varchar", is_nullable => 1, size => 1024 },
  "hostname",
  { data_type => "varchar", is_nullable => 1, size => 1024 },
);

=head1 PRIMARY KEY

=over 4

=item * L</rule_id>

=item * L</model_id>

=back

=cut

__PACKAGE__->set_primary_key("rule_id", "model_id");

=head1 RELATIONS

=head2 model

Type: belongs_to

Related object: L<ActiveCMDB::Schema::Result::DistModel>

=cut

__PACKAGE__->belongs_to(
  "model",
  "ActiveCMDB::Schema::Result::DistModel",
  { model_id => "model_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 rule_ep

Type: belongs_to

Related object: L<ActiveCMDB::Schema::Result::DistEndpoint>

=cut

__PACKAGE__->belongs_to(
  "rule_ep",
  "ActiveCMDB::Schema::Result::DistEndpoint",
  { ep_id => "rule_ep" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2012-10-30 14:31:29
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:YB13/3RglrHXdrnnwbTthA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
