use utf8;
package ActiveCMDB::Schema::Result::ConfigPolicy;

=head1 NAME

ActiveCMDB::Schema::Result::ConfigPolicy

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

__PACKAGE__->table("config_policy");

__PACKAGE__->add_columns(
  "policy_id",
  { 
  	data_type			=> "integer", 
  	is_auto_increment	=> 1, 
  	is_nullable			=> 0 
  },
  "active",
  {
  	data_type			=> "tinyint",
  	is_nullable		 	=> 0,
  	default_value		=> 0
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
  },
);

__PACKAGE__->set_primary_key("policy_id");

__PACKAGE__->has_many(
		rulesets => 'ActiveCMDB::Schema::Result::ConfigRuleset', 'policy_id'
);

__PACKAGE__->meta->make_immutable;
1;

