use utf8;
package ActiveCMDB::Schema::Result::ConfigMatch;

=head1 NAME

ActiveCMDB::Schema::Result::ConfigMatch

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

__PACKAGE__->table("config_match");

__PACKAGE__->add_columns(
  "match_id",
  {
  	data_type			=> "integer",
  	is_auto_increment	=> 1,
  	is_nullable			=> 0,
  },
  "rule_id",
  { 
  	data_type			=> "integer", 
  	is_auto_increment	=> 0, 
  	is_nullable			=> 0,
  	is_foreign_key		=> 1
  },
  "line_match",
  {
  	data_type			=> "varchar",
  	is_nullable			=> 0,
  	size				=> 255,
  	default_value		=> ""
  },
  "reverse",
  {
  	data_type			=> "tinyint",
  	is_nullable			=> 0,
  	default_value		=> 0
  },
);

__PACKAGE__->set_primary_key("match_id");

__PACKAGE__->meta->make_immutable;
1;