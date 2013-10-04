use utf8;
package ActiveCMDB::Schema::Result::CmdbMenu;

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

__PACKAGE__->table("cmdb_menu");


__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_nullable => 0, is_auto_increment => 1 },
  "label",
  { data_type => "varchar", is_nullable => 0, size => 32 },
  "icon",
  { data_type => "varchar", is_nullable => 1, size => 64 },
  "active",
  { data_type => "tinyint", is_nullable => 0 },
  "children",
  { data_type => "text", is_nullable => 1 },
  "url",
  { data_type => "text", is_nullable => 1 },
);


__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("label_UNIQUE", ["label"]);

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
