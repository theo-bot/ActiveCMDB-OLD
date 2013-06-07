use utf8;
package ActiveCMDB::Schema::Database::Result::IpConfigData;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

ActiveCMDB::Schema::Database::Result::IpConfigData

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

=head1 TABLE: C<ip_config_data>

=cut

__PACKAGE__->table("ip_config_data");

=head1 ACCESSORS

=head2 config_id

  data_type: 'bigint'
  is_auto_increment: 1
  is_nullable: 0

=head2 device_id

  data_type: 'integer'
  is_nullable: 1

=head2 config_date

  data_type: 'bigint'
  is_nullable: 1

=head2 config_checksum

  data_type: 'varchar'
  is_nullable: 1
  size: 45

=head2 config_status

  data_type: 'integer'
  is_nullable: 1

=head2 config_type

  data_type: 'varchar'
  is_nullable: 1
  size: 16

=head2 config_name

  data_type: 'varchar'
  is_nullable: 1
  size: 512

=cut

__PACKAGE__->add_columns(
  "config_id",
  { data_type => "bigint", is_auto_increment => 1, is_nullable => 0 },
  "device_id",
  { data_type => "integer", is_nullable => 1 },
  "config_date",
  { data_type => "bigint", is_nullable => 1 },
  "config_checksum",
  { data_type => "varchar", is_nullable => 1, size => 45 },
  "config_status",
  { data_type => "integer", is_nullable => 1 },
  "config_type",
  { data_type => "varchar", is_nullable => 1, size => 16 },
  "config_name",
  { data_type => "varchar", is_nullable => 1, size => 512 },
);

=head1 PRIMARY KEY

=over 4

=item * L</config_id>

=back

=cut

__PACKAGE__->set_primary_key("config_id");

=head1 RELATIONS

=head2 ip_config_object

Type: might_have

Related object: L<ActiveCMDB::Schema::Database::Result::IpConfigObject>

=cut

__PACKAGE__->might_have(
  "ip_config_object",
  "ActiveCMDB::Schema::Database::Result::IpConfigObject",
  { "foreign.config_id" => "self.config_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2012-08-17 15:21:52
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:hvZAu36jk5pnxPx4J0QQwA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
