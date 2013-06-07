use utf8;
package ActiveCMDB::Schema::Result::IpDeviceMaint;

=head1 NAME

ActiveCMDB::Schema::Result::Maintenance - Maintenance windows

=cut

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';

#
# Describe table
#
__PACKAGE__->table("ip_device_maint");

__PACKAGE__->add_columns(
  "device_id",
  { data_type => "integer", is_nullable => 0 },
  "maint_id",
  { data_type => "integer", is_nullable => 0 },
  "last_cycle",
  { data_type => "bigint", is_nullable => 0 },
  "tally",
  { data_type => "integer", is_nullable => 0 }
);

#
# Add primary key
#
__PACKAGE__->set_primary_key("device_id", "maint_id");

#
# Relations
#
__PACKAGE__->belongs_to(
	"device",
	"ActiveCMDB::Schema::Result::IpDevice",
	{ device_id => "device_id" },
	{ is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

__PACKAGE__->belongs_to(
	"maintenance",
	"ActiveCMDB::Schema::Result::Maintenance",
	{ maint_id => "maint_id" },
	{ is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

1;