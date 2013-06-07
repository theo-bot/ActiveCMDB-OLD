use utf8;
package ActiveCMDB::Schema::Database::Result::IpDeviceJournal;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

ActiveCMDB::Schema::Database::Result::IpDeviceJournal

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

=head1 TABLE: C<ip_device_journal>

=cut

__PACKAGE__->table("ip_device_journal");

=head1 ACCESSORS

=head2 journal_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 journal_date

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 device_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 user

  data_type: 'varchar'
  is_nullable: 0
  size: 16

=head2 journal_data

  data_type: 'varchar'
  is_nullable: 1
  size: 1024

=head2 journal_prio

  data_type: 'integer'
  default_value: 0
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "journal_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "journal_date",
  {
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
  "device_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "user",
  { data_type => "varchar", is_nullable => 0, size => 16 },
  "journal_data",
  { data_type => "varchar", is_nullable => 1, size => 1024 },
  "journal_prio",
  { data_type => "integer", default_value => 0, is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</journal_id>

=back

=cut

__PACKAGE__->set_primary_key("journal_id");

=head1 RELATIONS

=head2 device

Type: belongs_to

Related object: L<ActiveCMDB::Schema::Database::Result::IpDevice>

=cut

__PACKAGE__->belongs_to(
  "device",
  "ActiveCMDB::Schema::Database::Result::IpDevice",
  { device_id => "device_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2012-08-17 15:21:52
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:tU9eZlBtHzArS5+NUOpaZQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
