use utf8;
package ActiveCMDB::Schema::Result::DistEndpoint;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

ActiveCMDB::Schema::Result::DistEndpoint - Distribution endpoints

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

=head1 TABLE: C<dist_endpoint>

=cut

__PACKAGE__->table("dist_endpoint");

=head1 ACCESSORS

=head2 ep_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 ep_name

  data_type: 'varchar'
  is_nullable: 1
  size: 32

=head2 ep_method

  data_type: 'varchar'
  is_nullable: 1
  size: 8

=head2 ep_active

  data_type: 'tinyint'
  default_value: 1
  is_nullable: 1

=head2 ep_dest_in

  data_type: 'varchar'
  is_nullable: 1
  size: 1024

=head2 ep_dest_out

  data_type: 'varchar'
  is_nullable: 1
  size: 1024

=head2 ep_user

  data_type: 'varchar'
  is_nullable: 1
  size: 16

=head2 ep_encrypt

  data_type: 'integer'
  is_nullable: 1

=head2 ep_password

  data_type: 'varchar'
  is_nullable: 1
  size: 1024

=head2 ep_dest_key

  data_type: 'varchar'
  is_nullable: 1
  size: 1024

=head2 ep_create

  data_type: 'char'
  is_nullable: 1
  size: 1

=head2 ep_update

  data_type: 'char'
  is_nullable: 1
  size: 1

=head2 ep_delete

  data_type: 'char'
  is_nullable: 1
  size: 1

=head2 ep_create_data

  data_type: 'blob'
  is_nullable: 1

=head2 ep_update_data

  data_type: 'blob'
  is_nullable: 1

=head2 ep_delete_data

  data_type: 'blob'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "ep_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "ep_name",
  { data_type => "varchar", is_nullable => 1, size => 32 },
  "ep_method",
  { data_type => "varchar", is_nullable => 1, size => 8 },
  "ep_active",
  { data_type => "tinyint", default_value => 1, is_nullable => 1 },
  "ep_dest_in",
  { data_type => "varchar", is_nullable => 1, size => 1024 },
  "ep_dest_out",
  { data_type => "varchar", is_nullable => 1, size => 1024 },
  "ep_user",
  { data_type => "varchar", is_nullable => 1, size => 16 },
  "ep_encrypt",
  { data_type => "integer", is_nullable => 1 },
  "ep_password",
  { data_type => "varchar", is_nullable => 1, size => 1024 },
  "ep_dest_key",
  { data_type => "varchar", is_nullable => 1, size => 1024 },
  "ep_network_data",
  { data_type => 'varchar', is_nullable => 1, size => 128 },
 
);

=head1 PRIMARY KEY

=over 4

=item * L</ep_id>

=back

=cut

__PACKAGE__->set_primary_key("ep_id");

=head1 UNIQUE CONSTRAINTS

=head2 C<ep_name_UNIQUE>

=over 4

=item * L</ep_name>

=back

=cut

__PACKAGE__->add_unique_constraint("ep_name_UNIQUE", ["ep_name"]);

=head1 RELATIONS

=head2 dist_rules

Type: has_many

Related object: L<ActiveCMDB::Schema::Result::DistRule>

=cut

__PACKAGE__->has_many(
  "dist_rules",
  "ActiveCMDB::Schema::Result::DistRule",
  { "foreign.rule_ep" => "self.ep_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2012-10-30 14:31:29
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:NUsjbW6Ue8tw2GiDrUnW2Q


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
