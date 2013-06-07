use utf8;
package ActiveCMDB::Schema::Database::Result::DeviceLog;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

ActiveCMDB::Schema::Database::Result::DeviceLog

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

=head1 TABLE: C<device_log>

=cut

__PACKAGE__->table("device_log");

=head1 ACCESSORS

=head2 device_log_id

  data_type: 'bigint'
  is_auto_increment: 1
  is_nullable: 0

=head2 device_id

  data_type: 'integer'
  is_nullable: 1

=head2 ticket_number

  data_type: 'varchar'
  is_nullable: 1
  size: 32

=head2 device_log

  data_type: 'varchar'
  is_nullable: 1
  size: 45

=cut

__PACKAGE__->add_columns(
  "device_log_id",
  { data_type => "bigint", is_auto_increment => 1, is_nullable => 0 },
  "device_id",
  { data_type => "integer", is_nullable => 1 },
  "ticket_number",
  { data_type => "varchar", is_nullable => 1, size => 32 },
  "device_log",
  { data_type => "varchar", is_nullable => 1, size => 45 },
);

=head1 PRIMARY KEY

=over 4

=item * L</device_log_id>

=back

=cut

__PACKAGE__->set_primary_key("device_log_id");


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2012-08-17 15:21:52
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:/NkN0HeLxXQluNFHYAvQAQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
