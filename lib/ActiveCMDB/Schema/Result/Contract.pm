use utf8;
package ActiveCMDB::Schema::Result::Contract;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

ActiveCMDB::Schema::Result::Contract

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

=head1 TABLE: C<contracts>

=cut

__PACKAGE__->table("contracts");

=head1 ACCESSORS

=head2 contract_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 contract_number

  data_type: 'varchar'
  is_nullable: 1
  size: 32

=head2 contract_descr

  data_type: 'varchar'
  is_nullable: 1
  size: 32

=head2 vendor_id

  data_type: 'integer'
  is_nullable: 1

=head2 start_date

  data_type: 'date'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 end_date

  data_type: 'date'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 service_hours

  data_type: 'varchar'
  is_nullable: 1
  size: 32

=head2 internal_phone

  data_type: 'varchar'
  is_nullable: 1
  size: 32

=head2 internal_contact

  data_type: 'varchar'
  is_nullable: 1
  size: 64

=head2 contract_details

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "contract_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "contract_number",
  { data_type => "varchar", is_nullable => 1, size => 32 },
  "contract_descr",
  { data_type => "varchar", is_nullable => 1, size => 32 },
  "vendor_id",
  { data_type => "integer", is_nullable => 1 },
  "start_date",
  { data_type => "date", datetime_undef_if_invalid => 1, is_nullable => 1 },
  "end_date",
  { data_type => "date", datetime_undef_if_invalid => 1, is_nullable => 1 },
  "service_hours",
  { data_type => "varchar", is_nullable => 1, size => 32 },
  "internal_phone",
  { data_type => "varchar", is_nullable => 1, size => 32 },
  "internal_contact",
  { data_type => "varchar", is_nullable => 1, size => 64 },
  "contract_details",
  { data_type => "text", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</contract_id>

=back

=cut

__PACKAGE__->set_primary_key("contract_id");

=head1 UNIQUE CONSTRAINTS

=head2 C<CMDB110801>

=over 4

=item * L</contract_number>

=back

=cut

__PACKAGE__->add_unique_constraint("CMDB110801", ["contract_number"]);


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2012-10-30 14:31:29
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:R3LeFv56yxZJ54ehkYMIfw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
