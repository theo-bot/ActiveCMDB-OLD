package ActiveCMDB::Object::CmdbObject;

use Moose;
use ActiveCMDB::Model::CMDBv1;

# Schema
has 'schema'		=> (
	is		=> 'rw', 
	isa		=> 'Object', 
	default => sub { ActiveCMDB::Model::CMDBv1->instance() } 
);

1;