use 5.010;
use namespace::autoclean;
use MooseX::DeclareX
	keywords => [qw(class exception)],
	plugins  => [qw(public private)],
	types 	 => [ -Moose ]; 

class ActiveCMDB::Object::Number
{
	has	'value'		=> (
		is		=> 'rw',
		isa		=> 'Maybe[Any]'		
	);
	
	has 'required'	=> (
		is		=> 'rw',
		isa		=> 'Int'
	);
	
	has 'verify'	=> (
		is		=> 'rw',
		isa		=> 'Maybe[Str]'
	);
	
	has 'range'		=> (
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
		return if ( $self->required && !defined($self->value) );
		return if ( $self->value !~ /^\d+$/ );
		if ( defined($self->enum) && defined($self->value) )
		{
			my $found = 0;
			foreach ( split(/\,/, $self->enum) ) { if ( $self->value == $_ ) { $found = 1 } }
			return if ( $found == 0 )
		} 
		if ( defined($self->range) && defined($self->value) )
		{
			my($min,$max) = sort {$a <=> $b} split(/\,/, $self->range, 2);
			return if ( $self->value < $min || $self->value > $max );
		}
		
		return 1;
	}
};

1;