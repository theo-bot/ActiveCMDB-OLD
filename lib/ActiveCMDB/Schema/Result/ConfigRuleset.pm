use utf8;
package ActiveCMDB::Schema::Result::ConfigRuleset;

=head1 NAME

ActiveCMDB::Schema::Result::ConfigRuleset

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

__PACKAGE__->table("config_ruleset");

__PACKAGE__->add_columns(
  "set_id",
  { 
  	data_type			=> "integer", 
  	is_auto_increment	=> 1, 
  	is_nullable			=> 0 
  },
  "active",
  {
  	data_type			=> "tinyint",
  	is_nullable			=> 0,
  	default_value		=> 0
  },
  "policy_id",
  {
  	data_type			=> "integer",
  	is_nullable			=> 1, 	
  },
  "network_type",
  {
  	data_type			=> "integer",
  	is_nullable			=> 0,
  	default_value		=> 0
  },
  "vendor_id",
  {
  	data_type			=> "integer",
  	is_nullable			=> 1,
  },
  "description",
  {
  	data_type			=> "text",
  	is_nullable			=> 1
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
  }
 );
 
 __PACKAGE__->set_primary_key("set_id");



__PACKAGE__->has_many( 
	policies => 'ActiveCMDB::Schema::Result::ConfigPolicy', 'policy_id' 
);

__PACKAGE__->has_many(
	rules	=> 'ActiveCMDB::Schema::Result::ConfigRule', 'set_id'
);

__PACKAGE__->meta->make_immutable;
1;