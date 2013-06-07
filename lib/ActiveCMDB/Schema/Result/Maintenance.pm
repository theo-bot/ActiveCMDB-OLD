use utf8;
package ActiveCMDB::Schema::Result::Maintenance;

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
__PACKAGE__->table("maintenance");

__PACKAGE__->add_columns(
  "maint_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "start_date",
  { data_type => "bigint", is_nullable => 1 },
  "end_date",
  { data_type => "bigint", is_nullable => 1 },
  "start_time",
  { data_type => "integer", is_nullable => 0 },
  "end_time",
  { data_type => "integer", is_nullable => 0 },
  "m_repeat",
  { data_type => "integer", is_nullable => 0 },
  "m_interval",
  { data_type => "integer", is_nullable => 1},
  "descr",
  { datatype => "varchar", is_nullable => 0, size => 64 }
);

#
# Add primary key
#
__PACKAGE__->set_primary_key("maint_id");

1;