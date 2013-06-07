use utf8;
package ActiveCMDB::Schema::Result::IpDeviceAt;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

ActiveCMDB::Schema::Result::IpDeviceAt

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

=head1 TABLE: C<ip_device_at>

=cut

__PACKAGE__->table("ip_device_at");

=head1 ACCESSORS

=head2 device_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 atifindex

  data_type: 'integer'
  is_nullable: 1

=head2 atphysaddress

  data_type: 'varchar'
  is_nullable: 0
  size: 32

=head2 atnetaddress

  data_type: 'varchar'
  is_nullable: 0
  size: 256

=head2 disco

  data_type: 'bigint'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "device_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "atifindex",
  { data_type => "integer", is_nullable => 1 },
  "atphysaddress",
  { data_type => "varchar", is_nullable => 0, size => 32 },
  "atnetaddress",
  { data_type => "varchar", is_nullable => 0, size => 256 },
  "disco",
  { data_type => "bigint", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</device_id>

=item * L</atphysaddress>

=item * L</atnetaddress>

=back

=cut

__PACKAGE__->set_primary_key("device_id", "atphysaddress", "atnetaddress");

=head1 RELATIONS

=head2 device

Type: belongs_to

Related object: L<ActiveCMDB::Schema::Result::IpDevice>

=cut

__PACKAGE__->belongs_to(
  "device",
  "ActiveCMDB::Schema::Result::IpDevice",
  { device_id => "device_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2012-10-30 14:31:29
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:/1l7NJFa+dhPsQ8RayVs/A

__PACKAGE__->belongs_to(
	"interface",
	"ActiveCMDB::Schema::Result::IpDeviceInt",
	{
		device_id => "device_id",
		ifindex => "atifindex"
	}
);

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
