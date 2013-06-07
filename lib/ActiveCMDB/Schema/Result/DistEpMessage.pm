use utf8;
package ActiveCMDB::Schema::Result::DistEpMessage;

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime", "TimeStamp", "EncodedColumn");


__PACKAGE__->table("dist_epmessage");

__PACKAGE__->add_columns(
  "ep_id",
  { data_type => "integer", is_nullable => 0, is_auto_increment => 0 },
  "subject",
  { data_type => "varchar", is_nullable => 0, size => 32 },
  "active",
  { datatype => "tinyint", is_nullable => 0, default_value => 0 },
  "message",
  { datatype => "blob" },
  "mimetype",
  { datatype => "varchar", is_nullable => 0, size => 64 },
 );
 
 __PACKAGE__->set_primary_key("ep_id", "subject");
 
 __PACKAGE__->has_many(
  "messages",
  "ActiveCMDB::Schema::Result::DistMessage",
  { "foreign.subject" => "self.subject" },
  { cascade_copy => 1, cascade_delete => 1 },
);
  


__PACKAGE__->meta->make_immutable;
1;