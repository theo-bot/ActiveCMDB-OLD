use utf8;
package ActiveCMDB::Schema::Result::DistMessage;

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';


__PACKAGE__->table("dist_message");

__PACKAGE__->add_columns(
  "subject",
  { data_type => "varchar", is_nullable => 0, size => 32 },
  "mimetype",
  { data_type => "varchar", is_nullable => 0, size => 64 },
  "description",
  { data_type => "varchar", is_nullable => 0, size => 64 },
 );
 
 __PACKAGE__->set_primary_key("subject");

__PACKAGE__->meta->make_immutable;
1;