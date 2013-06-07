use utf8;
package ActiveCMDB::Schema::Result::IpDeviceTicket;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

ActiveCMDB::Schema::Result::IpDeviceTicket

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

=head1 TABLE: C<ip_device_ticket>

=cut

__PACKAGE__->table("ip_device_ticket");

=head1 ACCESSORS

=head2 device_id

  data_type: 'integer'
  is_nullable: 0

=head2 ticket_id

  data_type: 'varchar'
  is_nullable: 0
  size: 32

=head2 source

  data_type: 'varchar'
  is_nullable: 1
  size: 64

=head2 date_open

  data_type: 'bigint'
  is_nullable: 1

=head2 date_closed

  data_type: 'bigint'
  is_nullable: 1

=head2 description

  data_type: 'varchar'
  is_nullable: 1
  size: 1024

=cut

__PACKAGE__->add_columns(
  "device_id",
  { data_type => "integer", is_nullable => 0 },
  "ticket_id",
  { data_type => "varchar", is_nullable => 0, size => 32 },
  "source",
  { data_type => "varchar", is_nullable => 1, size => 64 },
  "date_open",
  { data_type => "bigint", is_nullable => 1 },
  "date_closed",
  { data_type => "bigint", is_nullable => 1 },
  "description",
  { data_type => "varchar", is_nullable => 1, size => 1024 },
);

=head1 PRIMARY KEY

=over 4

=item * L</device_id>

=item * L</ticket_id>

=back

=cut

__PACKAGE__->set_primary_key("device_id", "ticket_id");


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2012-10-30 14:31:29
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:oMiJ5r3928kdq8obx88RFw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
