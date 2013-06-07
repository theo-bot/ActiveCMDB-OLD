package ActiveCMDB::Object::Vendor;

#
# Include required modules 
#
use Moose;
use Moose::Util::TypeConstraints;
use Try::Tiny;
use Logger;

has 'id'			=> (is => 'ro',	isa => 'Str');
has 'name'			=> (is => 'rw', isa => 'Str');
has 'phone'			=> (is => 'rw', isa => 'Str');
has 'support_phone'	=> (is => 'rw', isa => 'Str');
has 'support_email'	=> (is => 'rw', isa => 'Str');
has 'support_www'	=> (is => 'rw', isa => 'Str');
has 'enterprises'	=> (is => 'rw', isa => 'Any');
has 'details'		=> (is => 'rw', isa => 'Any');

# Schema
has 'schema'		=> (is => 'rw', isa => 'Object', default => sub { ActiveCMDB::Schema->connect(ActiveCMDB::Model::CMDBv1->config()->{connect_info}) } );

sub find
{
	my ($self) = @_;
	my($row,$attr);
	
	$row = $self->schema->resultset("Vendor")->find({vendor_id => $self->id});
	if ( defined($row) )
	{
		foreach $attr (qw/name phone support_phone support_email support_www enterprises details/)
		{
			my $m = 'vendor_' . $attr;
			$self->$attr($row->$m());
		}
	}
	
}

1;