package ActiveCMDB::Object::Import::Line;

use 5.010;
use Data::UUID;
use Data::Dumper;
use Logger;
use ActiveCMDB::Model::Cloud;
use JSON::XS;

use DateTime;
use MooseX::DeclareX
	keywords => [qw(class exception)],
	plugins  => [qw(public private)],
	types 	 => [ -Moose ]; 

my $ug     = new Data::UUID;
my $bucket = 'cmdbImportLines';
my $coder  = JSON::XS->new->utf8->pretty->allow_nonref;
class ActiveCMDB::Object::Import::Line
{
	with 'ActiveCMDB::Object::Methods';
	
	has lineId	=> (
		is		=> 'ro',
		isa		=> 'Str',
		default	=> sub { $ug->create_str(); }
	);
	
	has status	=> (
		is		=> 'rw',
		isa		=> 'Int'
	);
	
	has 'importId'	=> (
		is		=> 'rw',
		isa		=> 'Str'
	);
	
	has 'data'		=> (
		is		=> 'rw',
		isa		=> 'Str'
	);
	
	has 'ln'		=> (
		is		=> 'rw',
		isa		=> 'Int'
	);
	
	has 'schema'		=> (
			is => 'rw', 
			isa => 'Object', 
			default => sub { ActiveCMDB::Model::Cloud->new() } 
	);
	
	public method get_data {
		$self->schema->bucket($bucket);
		my $object = $self->schema->get( { key => $self->lineId } );
		
		if ( defined($object) )
		{
			foreach (keys %{$object->data})
			{
				next if (/lineId/ );
				if ( defined($object->data->{$_}) && $self->meta->get_attribute( $_ )->get_write_method ) 
				{
					Logger->debug("Populating attribute " . $_);
					$self->$_( $object->data->{$_} );
				}
			}
		}
	};
	
	public method save {
		$self->schema->bucket($bucket);
		
		my $object = $self->schema->get( { key => $self->lineId } );
		my $data = $self->to_hashref();
		if ( defined($object) )
		{
			Logger->info("Updating import line object " . $self->lineId );
			$self->schema->update({ key => $self->lineId, value => $coder->encode($data) } );
		} else {
			Logger->info("Creating new import line object " . $self->lineId ); 
			$self->schema->create({ key => $self->lineId, value => $coder->encode($data) } );
		}
	};
	
	public method delete {
		$self->schema->bucket($bucket);
		my $object = $self->schema->get( { key => $self->lineId } );
		if ( defined($object) )
		{
			$self->schema->delete({ key => $self->lineId });
		} else {
			Logger->info("Line object not found");
		}
	};
};