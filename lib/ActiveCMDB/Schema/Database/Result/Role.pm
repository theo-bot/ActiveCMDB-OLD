use utf8;
package ActiveCMDB::Schema::Database::Result::Role;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

ActiveCMDB::Schema::Database::Result::Role - Role definitions

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

=head1 TABLE: C<roles>

=cut

__PACKAGE__->table("roles");

=head1 ACCESSORS

=head2 role_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 role_name

  data_type: 'varchar'
  is_nullable: 0
  size: 64

=head2 role_active

  data_type: 'tinyint'
  default_value: 1
  is_nullable: 1

=head2 role_type

  data_type: 'integer'
  default_value: 2
  is_nullable: 1

=head2 role_descr

  data_type: 'varchar'
  is_nullable: 1
  size: 128

=cut

__PACKAGE__->add_columns(
  "role_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "role_name",
  { data_type => "varchar", is_nullable => 0, size => 64 },
  "role_active",
  { data_type => "tinyint", default_value => 1, is_nullable => 1 },
  "role_type",
  { data_type => "integer", default_value => 2, is_nullable => 1 },
  "role_descr",
  { data_type => "varchar", is_nullable => 1, size => 128 },
);

=head1 PRIMARY KEY

=over 4

=item * L</role_id>

=back

=cut

__PACKAGE__->set_primary_key("role_id");

=head1 UNIQUE CONSTRAINTS

=head2 C<role_name>

=over 4

=item * L</role_name>

=back

=cut

__PACKAGE__->add_unique_constraint("role_name", ["role_name"]);

=head1 RELATIONS

=head2 group_roles

Type: has_many

Related object: L<ActiveCMDB::Schema::Database::Result::GroupRole>

=cut

__PACKAGE__->has_many(
  "group_roles",
  "ActiveCMDB::Schema::Database::Result::GroupRole",
  { "foreign.role_id" => "self.role_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 gids

Type: many_to_many

Composing rels: L</group_roles> -> gid

=cut

__PACKAGE__->many_to_many("gids", "group_roles", "gid");


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2012-08-17 15:21:52
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:HpPYDOrHl0RrZfDDoJEE4g


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
