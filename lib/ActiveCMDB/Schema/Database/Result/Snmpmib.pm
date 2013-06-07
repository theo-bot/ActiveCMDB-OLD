use utf8;
package ActiveCMDB::Schema::Database::Result::Snmpmib;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

ActiveCMDB::Schema::Database::Result::Snmpmib

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

=head1 TABLE: C<snmpmib>

=cut

__PACKAGE__->table("snmpmib");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 oid

  data_type: 'varchar'
  is_nullable: 1
  size: 256

=head2 oidname

  data_type: 'varchar'
  is_nullable: 1
  size: 256

=head2 type

  data_type: 'integer'
  is_nullable: 1

=head2 value

  data_type: 'varchar'
  is_nullable: 1
  size: 512

=head2 mibvalue

  data_type: 'varchar'
  is_nullable: 1
  size: 512

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "oid",
  { data_type => "varchar", is_nullable => 1, size => 256 },
  "oidname",
  { data_type => "varchar", is_nullable => 1, size => 256 },
  "type",
  { data_type => "integer", is_nullable => 1 },
  "value",
  { data_type => "varchar", is_nullable => 1, size => 512 },
  "mibvalue",
  { data_type => "varchar", is_nullable => 1, size => 512 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<oid_UNIQUE>

=over 4

=item * L</oid>

=item * L</value>

=back

=cut

__PACKAGE__->add_unique_constraint("oid_UNIQUE", ["oid", "value"]);

=head2 C<oid_name>

=over 4

=item * L</oidname>

=item * L</value>

=back

=cut

__PACKAGE__->add_unique_constraint("oid_name", ["oidname", "value"]);


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2012-08-17 15:21:52
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:i+v6wDjmS3ilAGBtLDxFXA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
