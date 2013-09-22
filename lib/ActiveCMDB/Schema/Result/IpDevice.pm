use utf8;
package ActiveCMDB::Schema::Result::IpDevice;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

ActiveCMDB::Schema::Result::IpDevice

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

=head1 TABLE: C<ip_device>

=cut

__PACKAGE__->table("ip_device");

=head1 ACCESSORS

=head2 device_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 hostname

  data_type: 'varchar'
  is_nullable: 1
  size: 128

=head2 mgtaddress

  data_type: 'varchar'
  is_nullable: 1
  size: 128

=head2 sysobjectid

  data_type: 'varchar'
  is_nullable: 1
  size: 128

=head2 status

  data_type: 'integer'
  is_nullable: 1

=head2 disco

  data_type: 'bigint'
  default_value: 0
  is_nullable: 1

=head2 device_type

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=head2 contract_id

  data_type: 'integer'
  is_nullable: 1

=head2 location_id

  data_type: 'integer'
  is_nullable: 1

=head2 category

  data_type: 'integer'
  is_nullable: 1

=head2 sysuptime

  data_type: 'bigint'
  is_nullable: 1

=head2 sysdescr

  data_type: 'varchar'
  is_nullable: 1
  size: 512

=head2 external_id

  data_type: 'varchar'
  is_nullable: 1
  size: 128

=head2 added

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 is_critical

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 1

=head2 is_ssh

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 1

=head2 is_telnet

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 1

=head2 tftpset

  data_type: 'varchar'
  default_value: 'DEFAULT'
  is_nullable: 1
  size: 32

=head2 os_type

  data_type: 'varchar'
  default_value: 'DEFAULT'
  is_nullable: 1
  size: 32
  
=head2 os_version

  data_type: 'varchar'
  default_value: 'DEFAULT'
  is_nullable: 1
  size: 16

=cut

__PACKAGE__->add_columns(
  "device_id",
  { 
  	data_type 		  => "integer", 
  	is_auto_increment => 1, 
  	is_nullable 	  => 0 },
  "hostname",
  { 
  	data_type   => "varchar", 
  	is_nullable => 1, 
  	size        => 128 
  },
  "mgtaddress",
  { data_type => "varchar", is_nullable => 1, size => 128 },
  "sysobjectid",
  { data_type => "varchar", is_nullable => 1, size => 128 },
  "status",
  { data_type => "integer", is_nullable => 1 },
  "disco",
  { data_type => "bigint", default_value => 0, is_nullable => 1 },
  "device_type",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "contract_id",
  { data_type => "integer", is_nullable => 1 },
  "location_id",
  { data_type => "integer", is_nullable => 1 },
  "domain_id",
  {
  	data_type	=> "integer",
  	is_nullable	=> 1
  },
  "category",
  { 
  	data_type => "integer", 
  	is_nullable => 1 
  },
  "sysuptime",
  { 
  	data_type => "bigint", 
  	is_nullable => 1 
  },
  "sysdescr",
  { 
  	data_type => "varchar", 
  	is_nullable => 1, 
  	size => 512 
  },
  "external_id",
  { 
  	data_type => "varchar", 
  	is_nullable => 1, 
  	size => 128 
  },
  "added",
  {
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
  "is_critical",
  { 
  	data_type => "tinyint", 
  	default_value => 0, 
  	is_nullable => 1 
  },
  "is_ssh",
  { 
  	data_type => "tinyint", 
  	default_value => 0, 
  	is_nullable => 1 
  },
  "is_telnet",
  { 
  	data_type => "tinyint", 
  	default_value => 0, 
  	is_nullable => 1 
  },
  "tftpset",
  {
    data_type => "varchar",
    default_value => "DEFAULT",
    is_nullable => 1,
    size => 32,
  },
  "discotime",
  {
  	data_type => "integer",
  	default_value => 0,
  	is_nullable => 0
  },
  "configtime",
  {
  	data_type => "integer",
  	default_value => 0,
  	is_nullable => 0
  },
  "os_type",
  {
    data_type => "varchar",
    default_value => "DEFAULT",
    is_nullable => 1,
    size => 32,
  },
  "os_version",
  {
    data_type => "varchar",
    default_value => "DEFAULT",
    is_nullable => 1,
    size => 16,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</device_id>

=back

=cut

__PACKAGE__->set_primary_key("device_id");

=head1 UNIQUE CONSTRAINTS

=head2 C<mgtaddres>

=over 4

=item * L</mgtaddress>

=back

=cut

__PACKAGE__->add_unique_constraint("mgtaddres", ["mgtaddress"]);

=head1 RELATIONS

=head2 ip_device_entities

Type: has_many

Related object: L<ActiveCMDB::Schema::Result::IpDeviceEntity>

=cut

__PACKAGE__->has_many(
  "ip_device_entities",
  "ActiveCMDB::Schema::Result::IpDeviceEntity",
  { "foreign.device_id" => "self.device_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 ip_device_ints

Type: has_many

Related object: L<ActiveCMDB::Schema::Result::IpDeviceInt>

=cut

__PACKAGE__->has_many(
  "ip_device_ints",
  "ActiveCMDB::Schema::Result::IpDeviceInt",
  { "foreign.device_id" => "self.device_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 ip_device_journals

Type: has_many

Related object: L<ActiveCMDB::Schema::Result::IpDeviceJournal>

=cut

__PACKAGE__->has_many(
  "ip_device_journals",
  "ActiveCMDB::Schema::Result::IpDeviceJournal",
  { "foreign.device_id" => "self.device_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 ip_device_macs

Type: has_many

Related object: L<ActiveCMDB::Schema::Result::IpDeviceMac>

=cut

__PACKAGE__->has_many(
  "ip_device_macs",
  "ActiveCMDB::Schema::Result::IpDeviceMac",
  { "foreign.device_id" => "self.device_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 ip_device_sec

Type: might_have

Related object: L<ActiveCMDB::Schema::Result::IpDeviceSec>

=cut

__PACKAGE__->might_have(
  "ip_device_sec",
  "ActiveCMDB::Schema::Result::IpDeviceSec",
  { "foreign.device_id" => "self.device_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 ip_devices_at

Type: has_many

Related object: L<ActiveCMDB::Schema::Result::IpDeviceAt>

=cut

__PACKAGE__->has_many(
  "ip_devices_at",
  "ActiveCMDB::Schema::Result::IpDeviceAt",
  { "foreign.device_id" => "self.device_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2012-10-30 14:31:29
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:2EGRFfAPeQ5O9VqGDE3XeA

__PACKAGE__->has_many(
	"sysoids",
	"ActiveCMDB::Schema::Result::IpDeviceType",
	{ "foreign.sysObjectID" => "self.sysObjectID"},
	{ join_type => 'INNER' }
);

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
