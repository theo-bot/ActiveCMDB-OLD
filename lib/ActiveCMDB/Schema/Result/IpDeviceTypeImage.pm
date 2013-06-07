use utf8;
package ActiveCMDB::Schema::Result::IpDeviceTypeImage;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

ActiveCMDB::Schema::Result::IpDeviceTypeImage - Device types

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

#__PACKAGE__->load_components("InflateColumn::DateTime", "TimeStamp", "EncodedColumn");

=head1 TABLE: C<ip_device_type>

=cut

__PACKAGE__->table("ip_device_type_image");

=head1 ACCESSORS

=head2 type_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0



=cut

__PACKAGE__->add_columns(
  "type_id",
  { data_type => "integer", is_auto_increment => 0, is_nullable => 0 },
  "mime_type",
  { data_type => "varchar", is_nullable => 1, size => 64 },
  "image",
  { data_type => "blob" }
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("type_id");

=head1 UNIQUE CONSTRAINTS

=head2 C<sysObjectID_UNIQUE>

=over 4

=item * L</sysobjectid>

=back

=cut

# Created by DBIx::Class::Schema::Loader v0.07025 @ 2012-10-30 14:31:29
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:eypxvWXNP5cSaG5QdGgfGw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
