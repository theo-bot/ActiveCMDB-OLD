use utf8;
package ActiveCMDB::Schema::Result::IpDomainNetwork;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

ActiveCMDB::Schema::Result::IpDomainNetwork

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

=head1 TABLE: C<ip_domain_network>

=cut

__PACKAGE__->table("ip_domain_network");

=head1 ACCESSORS

=head2 domain_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 ip_network

  data_type: 'varchar'
  default_value: '0.0.0.0'
  is_nullable: 0
  size: 512

=head2 ip_mask

  data_type: 'varchar'
  default_value: '255.255.255.0'
  is_nullable: 0
  size: 45

=head2 ip_masklen

  data_type: 'integer'
  default_value: 32
  is_nullable: 1

=head2 active

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 1

=head2 last_update

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 ip_order

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "network_id",
  { data_type => "integer", is_nullable => 0, is_auto_increment => 1 },
  "domain_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "ip_network",
  {
    data_type => "varchar",
    default_value => "0.0.0.0",
    is_nullable => 0,
    size => 512,
  },
  "ip_mask",
  {
    data_type => "varchar",
    default_value => "255.255.255.0",
    is_nullable => 0,
    size => 45,
  },
  "ip_masklen",
  { data_type => "integer", default_value => 32, is_nullable => 1 },
  "active",
  { data_type => "tinyint", default_value => 0, is_nullable => 1 },
  "last_update",
  {
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
  "ip_order",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "snmp_ro",
  {
  	data_type => "varchar",
    default_value => "public",
    is_nullable => 1,
    size => 32,
  },
  "snmp_rw",
  {
  	data_type => "varchar",
    default_value => "private",
    is_nullable => 1,
    size => 32,
  },
  "telnet_user",
  {
  	data_type => "varchar",
    default_value => "",
    is_nullable => 1,
    size => 32,
  },
  "telnet_pwd",
  {
  	data_type => "varchar",
  	default_value => "",
  	is_nullable => 1,
  	size => 16,
  },
  "snmpv3_user",
  {
  	data_type => "varchar",
  	default_value => "",
  	is_nullable => 1,
  	size => 16,
  },
  "snmpv3_pass1",
  {
  	data_type => "varchar",
  	default_value => "",
  	is_nullable => 1,
  	size => 64,
  },
  "snmpv3_pass2",
  {
	data_type => "varchar",
  	default_value => "",
  	is_nullable => 1,
  	size => 16,
  },
  "snmpv3_proto1",
  {
  	data_type => "varchar",
  	default_value => "",
  	is_nullable => 1,
  	size => 8,
  },
  "snmpv3_proto2",
  {
  	data_type => "varchar",
  	default_value => "",
  	is_nullable => 1,
  	size => 8,
  }
);

=head1 PRIMARY KEY

=over 4

=item * L</domain_id>

=item * L</ip_network>

=back

=cut

__PACKAGE__->set_primary_key("network_id");

=head1 RELATIONS

=head2 domain

Type: belongs_to

Related object: L<ActiveCMDB::Schema::Result::IpDomain>

=cut

__PACKAGE__->belongs_to(
  "domain",
  "ActiveCMDB::Schema::Result::IpDomain",
  { domain_id => "domain_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2012-10-30 14:31:29
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:TFkVUh/yZ5QOlNxXT3kM2Q


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
