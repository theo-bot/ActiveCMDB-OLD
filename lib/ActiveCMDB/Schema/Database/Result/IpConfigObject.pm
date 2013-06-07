use utf8;
package ActiveCMDB::Schema::Database::Result::IpConfigObject;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

ActiveCMDB::Schema::Database::Result::IpConfigObject

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

=head1 TABLE: C<ip_config_object>

=cut

__PACKAGE__->table("ip_config_object");

=head1 ACCESSORS

=head2 config_id

  data_type: 'bigint'
  is_foreign_key: 1
  is_nullable: 0

=head2 config_data

  data_type: 'blob'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "config_id",
  { data_type => "varchar", is_foreign_key => 1, is_nullable => 0, size => 48 },
  "config_data",
  { data_type => "blob", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</config_id>

=back

=cut

__PACKAGE__->set_primary_key("config_id");

=head1 RELATIONS

=head2 config

Type: belongs_to

Related object: L<ActiveCMDB::Schema::Database::Result::IpConfigData>

=cut

__PACKAGE__->belongs_to(
  "config",
  "ActiveCMDB::Schema::Database::Result::IpConfigData",
  { config_id => "config_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2012-08-17 15:21:52
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:a4iAtfoirb2kpfC/YBYyMw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
