package ActiveCMDB::Object::Import;

use 5.010;
use Data::UUID;
use Data::Dumper;
use Logger;
use ActiveCMDB::Model::Cloud;
use ActiveCMDB::Object::Import::Line;
use JSON::XS;

use DateTime;
use MooseX::DeclareX
	keywords => [qw(class exception)],
	plugins  => [qw(public private)],
	types 	 => [ -Moose ]; 

my $ug     = new Data::UUID;
my $bucket = 'cmdbImport';
my $coder  = JSON::XS->new->utf8->pretty->allow_nonref;
my %impStatus = (
	0	=> 'Stored',
	1	=> 'Imported',
	2	=> 'Failed',
	3	=> 'Corrupted'
);

my %map = (
	id			=> 'id',
	filename	=> 'filename',
	username	=> 'username',
	upload_time	=> 'upload_time',
	tally		=> 'tally',
	checksum	=> 'checksum',
	object_type		=> 'object_type',
	status		=> 'status',
	progress	=> 'progress',
	dt			=> 'dt',
);


class ActiveCMDB::Object::Import
{

	with 'ActiveCMDB::Object::Methods';

	has 'id'		=> (
			is		=> 'ro', 
			isa		=> 'Str',
			default	=> sub { $ug->create_str(); }
	);
	
	has 'filename'		=> (
			is		=> 'rw', 
			isa		=> 'Str'
	);
	
	has 'username'		=> (
			is		=> 'rw', 
			isa		=> 'Str'
	);
	
	has 'upload_time'	=> (
			is		=>	'rw',
			isa		=>	'Int',
			default	=> 0
	);
		
	has 'tally'			=> (
			is		=> 'rw',
			isa		=> 'Int',
			default	=> 0
	);
	
	has 'checksum'		=> (
			is		=> 'rw',
			isa		=> 'Str',
			default	=> ''
	);
	
	has 'lines'		=> (
			traits	=> ['Array'],
			is		=> 'ro',
			isa		=> 'ArrayRef[Object]',
			default	=> sub { [] },
			handles	=> {
				add_line		=> 'push',
				count_lines		=> 'count',
				insert_line		=> 'insert',
				delete_line		=> 'delete',
				all_lines		=> 'elements',
				clear_lines		=> 'clear'
			},
	);
	
	has 'object_type'	=> (
			is		=> 'rw',
			isa		=> 'Str',
			default	=> ''
	);
	
	has 'status'		=> (
			is		=> 'rw',
			isa		=> 'Int',
			default	=> 0
	);
	
	has 'progress'			=> (
			is		=> 'rw',
			isa		=> 'Int',
			default	=> 0
	);
	
	has 'dt'			=> (
			is		=> 'ro',
			isa		=> 'Str',
			default	=> 'cmdbImport'
	);
	
	has 'schema'		=> (
			is => 'rw', 
			isa => 'Object', 
			default => sub { ActiveCMDB::Model::Cloud->new() } 
	);
	
	public method save {
		use Logger;
		
		
		$self->schema->bucket($bucket);
		Logger->info("Verify if object id " . $self->id . " exists");
		my $object = $self->schema->get( { key => $self->id } );
		
		my $data = $self->to_hashref(\%map);
		if ( defined($object) )
		{
			Logger->info("Updating import object " . $self->id );
			$self->schema->update({ key => $self->id, value => $coder->encode($data) } );
		} else {
			Logger->info("Creating new import object " . $self->id); 
			$self->schema->create({ key => $self->id, value => $coder->encode($data) } );
		}
		
		if ( $self->count_lines() > 0 )
		{
			Logger->info("Saving " .$self->count_lines() . " lines.");
			foreach my $line ($self->all_lines() )
			{
				$line->save();
			}
		} else {
			Logger->warn("No lines to save");
		}
	}
	
	public method get_data {
		use Logger;
		Logger->debug("Fetching data for ".$self->id);
		$self->schema->bucket($bucket);
		my $object = $self->schema->get( { key => $self->id } );
		
		if ( defined($object) )
		{
			#
			# Fetch import object
			#
			foreach (keys %{$object->data})
			{
				next if (/id|lines/ );
				if ( defined($object->data->{$_}) && $self->meta->get_attribute( $_ )->get_write_method ) 
				{
					Logger->debug("Populating attribute " . $_);
					$self->$_( $object->data->{$_} );
				}
			}
			
			#
			# Fetch import lines
			#
			
			$self->getLines();
			if ( $self->count_lines() > 0 )
			{
				Logger->info("Found " . $self->count_lines() . " lines for import " . $self->id );
			} else {
				Logger->warn("No lines found");
			}
			
		} else {
			Logger->warn("Object not found");
			return;
		}
	}
	
	public method delete {
		$self->schema->bucket($bucket);
		my $object = $self->schema->get( { key => $self->id } );
		if ( defined($object) )
		{
			$self->getLines();
			foreach my $line ($self->all_lines())
			{
				$line->delete();	
			}
			$self->schema->delete({ key => $self->id });
		}
	}
	
	public method upload {
		my $dt = DateTime->from_epoch(epoch => $self->upload_time);
		return sprintf("%s %s", $dt->ymd, $dt->hms);
	}
	
	public method state {
		return $impStatus{$self->status};
	}
	
	private method getLines {
		my $query = 'importId:' . $self->id;
		my $order = 'ln';
		my $res = $self->schema->client->search(index => 'cmdbImportLines', sort => $order, q => $query, wt => 'json' );
		
		if ( $res->{response}->{numFound} > 0 )
		{
			$self->clear_lines();
			foreach my $doc ( @{$res->{response}->{docs}} )
			{
				#Logger->debug(Dumper($doc));
				my $importLine = ActiveCMDB::Object::Import::Line->new(lineId => $doc->{fields}->{lineId});
				$importLine->get_data();
				$self->add_line($importLine);
			}
		}
		
	}
};