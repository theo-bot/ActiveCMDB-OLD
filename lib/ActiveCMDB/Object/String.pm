package ActiveCMDB::Object::String;

use 5.010;
use namespace::autoclean;
use MooseX::DeclareX
	keywords => [qw(class exception)],
	plugins  => [qw(public private)],
	types 	 => [ -Moose ]; 

class ActiveCMDB::Object::String
{
	has	'value'		=> (
		is		=> 'rw',
		isa		=> 'Maybe[Any]'		
	);
	
	has 'required'	=> (
		is		=> 'rw',
		isa		=> 'Int',
		default	=> 0
	);
	
	has 'verify'	=> (
		is		=> 'rw',
		isa		=> 'Maybe[Str]'
	);
	
	has 'enum'		=> (
		is		=> 'rw',
		isa		=> 'Maybe[Str]'
	);
	
	has 'map'		=> (
		is		=> 'rw',
		isa		=> 'Maybe[Str]'
	);
	
	public method check {
		if ( $self->required && !defined($self->value) ) {
			return (0,"Undefined value, while required");
		}

		if ( defined($self->enum) && defined($self->value) )
		{
			my $found = 0;
			foreach ( split(/\,/, $self->enum) ) { if ( $self->value eq $_ ) { $found = 1 } }
			if ( $found == 0 ) {
				return (0, "Value not found in enum set");
			}
		} 
		
		return 1;
	}
};

1;