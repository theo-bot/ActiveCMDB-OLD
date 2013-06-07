package ActiveCMDB::Object::Message;

use JSON::XS;
use Data::Dumper;
use Logger;
use Moose;
use Data::UUID;

my $ug = new Data::UUID;

has 'payload'		=> ( is => 'rw', isa => 'Any' );
has 'from'			=> ( is => 'rw', isa => 'Str|Undef' );
has 'reply_to'		=> ( is => 'rw', isa => 'Str|Undef' );
has 'content_type'	=> ( is => 'rw', isa => 'Str|Undef' );
has 'cid'			=> ( is => 'rw', isa => 'Str|Undef' );
has 'subject'		=> ( is => 'rw', isa => 'Str' );
has 'to'			=> ( is => 'rw', isa => 'Str' );
has 'ts1'			=> ( is => 'rw', isa => 'Int|Undef' );
has 'muid'			=> ( 
							is => 'rw', 
							isa => 'Str',
							default => sub { $ug->create_str(); }  
						);			


sub encode_to_json {
	my($self) = @_;
	my $data = undef;
	foreach my $key (__PACKAGE__->meta->get_all_attributes) {
		my $attr = $key->name;
		if ( defined($self->$attr) ) 
		{
			Logger->debug("Adding $attr with value ".$self->$attr." to message");
			$data->{$attr} = $self->$attr;
		}
	}
	my $json = JSON::XS->new->utf8->pretty;

	return $json->encode($data);
}

sub decode_from_json {
	my($self, $msg) = @_;
	
	my $data = JSON::XS->new->utf8->decode($msg);
	
	
	foreach my $key (__PACKAGE__->meta->get_all_attributes ) {
		my $attr = $key->name;
		if ( defined($data->{$attr}) ) {
			$self->$attr($data->{$attr});
		}
	}
}

__PACKAGE__->meta->make_immutable;

1;