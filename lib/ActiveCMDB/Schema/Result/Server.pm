use utf8;
package ActiveCMDB::Schema::Result::Server;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

ActiveCMDB::Schema::Result::Server

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

=head1 TABLE: C<server>

=cut

__PACKAGE__->table("server");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_nullable: 0

=head2 servername

  data_type: 'varchar'
  is_nullable: 0
  size: 64

=head2 netaddr

  data_type: 'varchar'
  is_nullable: 0
  size: 128

=head2 active

  data_type: 'tinyint'
  is_nullable: 0

=head2 master

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_nullable => 0 },
  "servername",
  { data_type => "varchar", is_nullable => 0, size => 64 },
  "netaddr",
  { data_type => "varchar", is_nullable => 0, size => 128 },
  "active",
  { data_type => "tinyint", is_nullable => 0 },
  "master",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
);

=head1 UNIQUE CONSTRAINTS

=head2 C<id_UNIQUE>

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->add_unique_constraint("id_UNIQUE", ["id"]);

=head2 C<netaddr_UNIQUE>

=over 4

=item * L</netaddr>

=back

=cut

__PACKAGE__->add_unique_constraint("netaddr_UNIQUE", ["netaddr"]);

=head2 C<servername_UNIQUE>

=over 4

=item * L</servername>

=back

=cut

__PACKAGE__->add_unique_constraint("servername_UNIQUE", ["servername"]);


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2012-10-30 14:31:29
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Ua9U8G+3/zSPr5Xln4tevw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
