package ActiveCMDB::Object::IpType;

#
# Include required modules 
#
use Moose;
use Moose::Util::TypeConstraints;
use Try::Tiny;
use Logger;

has 'sysobjectid'	=> (is => 'ro',	isa => 'Str');
has 'descr'			=> (is => 'rw', isa => 'Str');
has 'vendor_id'		=> (is => 'rw', isa => 'Int');

# Schema
has 'schema'		=> (is => 'rw', isa => 'Object', default => sub { ActiveCMDB::Schema->connect(ActiveCMDB::Model::CMDBv1->config()->{connect_info}) } );

sub find
{
	my ($self) = @_;
	my($row);
	
	$row = $self->schema->resultset("IpDeviceType")->find({sysobjectid => $self->sysobjectid});
	if ( defined($row) )
	{
		foreach my $attr (qw/descr vendor_id/)
		{ 
			$self->$attr($row->$attr());
		}
		
	}
	
}

1;