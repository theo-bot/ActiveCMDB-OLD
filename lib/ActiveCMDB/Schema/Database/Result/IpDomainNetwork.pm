use utf8;
package ActiveCMDB::Schema::Database::Result::IpDomainNetwork;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

ActiveCMDB::Schema::Database::Result::IpDomainNetwork

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

=head2 ip_cidr

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
  "ip_cidr",
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
);

=head1 PRIMARY KEY

=over 4

=item * L</domain_id>

=item * L</ip_network>

=back

=cut

__PACKAGE__->set_primary_key("domain_id", "ip_network");

=head1 RELATIONS

=head2 domain

Type: belongs_to

Related object: L<ActiveCMDB::Schema::Database::Result::IpDomain>

=cut

__PACKAGE__->belongs_to(
  "domain",
  "ActiveCMDB::Schema::Database::Result::IpDomain",
  { domain_id => "domain_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2012-08-17 15:21:52
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:eLPihqiMr9/iUJZ8z78k6g


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
