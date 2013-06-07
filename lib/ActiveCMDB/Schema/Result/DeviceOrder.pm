use utf8;
package ActiveCMDB::Schema::Result::DeviceOrder;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

ActiveCMDB::Schema::Result::DeviceOrder

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

=head1 TABLE: C<device_orders>

=cut

__PACKAGE__->table("device_orders");

=head1 ACCESSORS

=head2 cid

  data_type: 'varchar'
  is_nullable: 0
  size: 48

=head2 device_id

  data_type: 'integer'
  is_nullable: 0

=head2 ts

  data_type: 'bigint'
  is_nullable: 0

=head2 dest

  data_type: 'varchar'
  is_nullable: 0
  size: 16

=cut

__PACKAGE__->add_columns(
  "cid",
  { data_type => "varchar", is_nullable => 0, size => 48 },
  "device_id",
  { data_type => "integer", is_nullable => 0 },
  "ts",
  { data_type => "bigint", is_nullable => 0 },
  "dest",
  { data_type => "varchar", is_nullable => 0, size => 16 },
);

=head1 PRIMARY KEY

=over 4

=item * L</cid>

=back

=cut

__PACKAGE__->set_primary_key("cid");


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2012-10-30 14:31:29
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:MQusO0SQrUyyGA/6ix83ZQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
