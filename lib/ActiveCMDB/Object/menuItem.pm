package ActiveCMDB::Object::menuItem;

use ActiveCMDB::Model::CMDBv1;
use Data::Dumper;
use MooseX::DeclareX
	keywords => [qw(class exception)],
	plugins  => [qw(public private)],
	types 	 => [ -Moose ]; 

class ActiveCMDB::Object::menuItem 
{
	has 'id' => (
		is		=> 'rw',
		isa		=> 'Int',
		default => 0
	);
	
	has 'label' => (
		is		 => 'rw',
		isa		 => 'Str',
		required => 1
	);
	
	has 'icon' => (
		is		 => 'rw',
		isa		 => 'Str',
	);
	
	has 'children' => (
		is		=> 'rw',
		isa		=> 'Str',
	);
	
	has 'url' => (
		is		=> 'rw',
		isa		=> 'Maybe[Str]',
	);
	
	has 'active' => (
		is		=> 'rw',
		isa		=> 'Bool',
		default	=> 1,
	);
	
	has 'schema'		=> (
		is		=> 'rw', 
		isa		=> 'Object', 
		default	=> sub { ActiveCMDB::Model::CMDBv1->instance() } 
	);
	
	with 'ActiveCMDB::Object::Methods';
	
	public method get_data {
		my $result = 0;
		#try {
			Logger->debug("BP");
			my $row = $self->schema->resultset("CmdbMenu")->find({ label => $self->label });
			
			if ( defined($row) )
			{
				Logger->debug("Parsing attributes");
				foreach my $attr (qw/id label icon children url active/)
				{
					if ( defined($row->$attr) ) {
						$self->$attr($row->$attr);
					}
				}
				$result = 1;
			} else {
				Logger->warn("Menu item " . $self->label . " not found.");
			}
		#} catch {
		#	Logger->warn("Failed to fetch data for ". $self->label . " " . $@ );
		#}
		
		return $result;
	};
	
	public method save {
		try {
			my $data = $self->to_hashref();
			Logger->info("Saving menuItem data");
			my $rs = $self->schema->resultset("CmdbMenu")->update_or_create($data);
			Logger->debug("Schema updated");
			if ( ! $rs->in_storage ) {
				$rs->insert;
			}
		
			return 1;
		} catch {
			Logger->error("Failed to save menu item: $@" );
			return;
		}
	};
};

1;