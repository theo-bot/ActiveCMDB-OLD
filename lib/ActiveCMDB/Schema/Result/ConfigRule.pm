use utf8;
package ActiveCMDB::Schema::Result::ConfigRule;

=head1 NAME

ActiveCMDB::Schema::Result::ConfigRule

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
__PACKAGE__->load_components("InflateColumn::DateTime", "TimeStamp");

=head1 TABLE: C<ip_device>

=cut

__PACKAGE__->table("config_rule");

__PACKAGE__->add_columns(
  "rule_id",
  { 
  	data_type			=> "integer", 
  	is_auto_increment	=> 1, 
  	is_nullable			=> 0 
  },
  "name",
  {
  	data_type			=> "varchar",
  	is_nullable			=> 0,
  	size				=> 128
  },
  "active",
  {
  	data_type			=> "tinyint",
  	is_nullable			=> 0,
  	default_value		=> 0
  },
  "set_id",
  {
  	data_type			=> "integer",
  	is_nullable			=> 1,
  },
  "regex_start",
  {
  	data_type			=> "varchar",
  	is_nullable			=> 0,
  	default_value		=> "",
  	size				=> 255
  },
  "regex_end",
  {
  	data_type			=> "varchar",
  	is_nullable			=> 0,
  	default_value		=> "",
  	size				=> 255
  },
  "os_version",
  {
  	data_type			=> "varchar",
  	is_nullable			=> 0,
  	default_value		=> "",
  	size				=> 128
  },
  "last_update",
  {
  	data_type			=> "bigint",
  	is_nullable			=> 0,
  	default_value		=> 0
  },
  "updated_by",
  {
  	data_type			=> "varchar",
  	is_nullable			=> 0,
  	size				=> 32
  },
  "description",
  {
  	data_type			=> "text",
  	is_nullable			=> 1
  }
);

 __PACKAGE__->set_primary_key("rule_id");
 
 __PACKAGE__->has_many(
 	matches	=> 'ActiveCMDB::Schema::Result::ConfigMatch', 'rule_id'
 );
 
 
 
__PACKAGE__->meta->make_immutable;
1;