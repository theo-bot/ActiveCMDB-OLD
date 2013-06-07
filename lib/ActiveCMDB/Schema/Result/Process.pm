use utf8;
package ActiveCMDB::Schema::Result::Process;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

ActiveCMDB::Schema::Result::Process

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

=head1 TABLE: C<process>

=cut

__PACKAGE__->table("process");

=head1 ACCESSORS

=head2 process_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 process_name

  data_type: 'varchar'
  is_nullable: 1
  size: 16

=head2 process_server

  data_type: 'integer'
  is_nullable: 1

=head2 process_status

  data_type: 'integer'
  is_nullable: 1

=head2 process_pid

  data_type: 'integer'
  is_nullable: 1

=head2 process_type

  data_type: 'integer'
  is_nullable: 1

=head2 process_path

  data_type: 'varchar'
  is_nullable: 1
  size: 256

=head2 process_comms

  data_type: 'varchar'
  is_nullable: 1
  size: 256

=head2 process_order

  data_type: 'integer'
  is_nullable: 1

=head2 process_update

  data_type: 'bigint'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "process_instance",
  { data_type => "integer", is_nullable => 0 },
  "process_name",
  { data_type => "varchar", is_nullable => 0, size => 16 },
  "process_server",
  { data_type => "integer", is_nullable => 0 },
  "process_status",
  { data_type => "integer", is_nullable => 1 },
  "process_pid",
  { data_type => "integer", is_nullable => 1 },
  "process_type",
  { data_type => "varchar", is_nullable => 1, size => 16 },
  "process_path",
  { data_type => "varchar", is_nullable => 1, size => 256 },
  "process_comms",
  { data_type => "varchar", is_nullable => 1, size => 256 },
  "process_order",
  { data_type => "integer", is_nullable => 1 },
  "process_update",
  { data_type => "bigint", is_nullable => 1 },
  "process_data",
  { data_type => "text", is_nullable => 1},
  "process_parent",
  { data_type => "integer", is_nullable => 1 },
  "updated_by",
  { data_type => "varchar", is_nullable => 1, size => 64 },
  "process_start",
  { data_type => "bigint", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</process_id>

=back

=cut

__PACKAGE__->set_primary_key("process_name", "process_server", "process_instance");

=head1 UNIQUE CONSTRAINTS

=head2 C<process_name_UNIQUE>

=over 4

=item * L</process_name>

=back

=cut


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2012-10-30 14:31:29
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:BSWZyErEtvyuo5cXno6HQQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
