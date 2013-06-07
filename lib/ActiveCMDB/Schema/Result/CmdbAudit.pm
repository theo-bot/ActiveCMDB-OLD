use utf8;
package ActiveCMDB::Schema::Result::CmdbAudit;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

ActiveCMDB::Schema::Result::CmdbAudit

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

=head1 TABLE: C<cmdb_audit>

=cut

__PACKAGE__->table("cmdb_audit");

=head1 ACCESSORS

=head2 object_id

  data_type: 'bigint'
  is_nullable: 0

=head2 audit_seq

  data_type: 'bigint'
  is_auto_increment: 1
  is_nullable: 0

=head2 object_type

  data_type: 'varchar'
  is_nullable: 1
  size: 128

=head2 audit_date

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 audit_user

  data_type: 'varchar'
  is_nullable: 1
  size: 32

=head2 audit_type

  data_type: 'integer'
  is_nullable: 1

=head2 audit_descr

  data_type: 'varchar'
  is_nullable: 1
  size: 1024

=cut

__PACKAGE__->add_columns(
  "object_id",
  { data_type => "bigint", is_nullable => 0 },
  "audit_seq",
  { data_type => "bigint", is_auto_increment => 1, is_nullable => 0 },
  "object_type",
  { data_type => "varchar", is_nullable => 1, size => 128 },
  "audit_date",
  {
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
  "audit_user",
  { data_type => "varchar", is_nullable => 1, size => 32 },
  "audit_type",
  { data_type => "integer", is_nullable => 1 },
  "audit_descr",
  { data_type => "varchar", is_nullable => 1, size => 1024 },
);

=head1 PRIMARY KEY

=over 4

=item * L</audit_seq>

=item * L</object_id>

=back

=cut

__PACKAGE__->set_primary_key("audit_seq", "object_id");


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2012-10-30 14:31:29
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:7e0VrqjIGyTzt6n2s3SVGQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
