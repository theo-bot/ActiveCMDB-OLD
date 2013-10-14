package ActiveCMDB::Object::NetAddress;

use 5.010;
use namespace::autoclean;


use MooseX::DeclareX
	keywords => [qw(class exception)],
	plugins  => [qw(public private)],
	types 	 => [ -Moose ]; 

class ActiveCMDB::Object::NetAddress
{
	has 'value'	=> (
		is			=> 'rw',
		isa			=> 'Str',
		required	=> 1
	);
	
	has 'maskbits'	=> (
		is			=> 'rw',
		isa			=> 'Int',
		default		=> 24
	);
	
	has 'prefix'	=> (
		is			=> 'rw',
		isa			=> 'Int'
	);

	has 'verify'	=> (
		is			=> 'rw',
		
	);	
	
	public method check {
		return if ( !defined($self->value) || !$self->value);
		try { 
			use Net::IP;
			Logger->debug("Creating new Net::IP object with value " . $self->value );
			my $v = $self->value;
			my $ip = new Net::IP( "$v" );
			if ( ! $ip->ip_get_version  ) {
				return (undef,"Invalid ip address");
			} else {
				Logger->debug("Address appears to be version " . $ip->ip_get_version );
			}
		} catch {
			Logger->warn("Failed to create new Net::IP object");
			return (undef, "Unable to create Net::IP object");
		};
		
		return 1;
	}
}

1;