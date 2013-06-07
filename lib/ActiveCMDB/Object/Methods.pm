package ActiveCMDB::Object::Methods;

use Data::Dumper;
use Logger;
use Moose::Role;

sub to_hashref
{
	my($self, $map) = @_;
	my($key,$attr,$data);
	
	$data = undef;
	
	
	if ( defined( $map ) )
	{
		my %map = %{$map};
		foreach $attr (keys %map)
		{
			$data->{ $map{$attr} } = $self->$attr;
		}	
	} else {
		foreach $key ( $self->meta->get_all_attributes )
		{
			$attr = $key->name;
			next if ( $attr =~ /schema/ );
			$data->{$attr} = $self->$attr();
		}
	}
	
	return $data;
}

sub populate
{
	my($self,$data, $map) = @_;
	
	if ( defined($map) )
	{
		my %map = %{$map};
		foreach my $attr (keys %map)
		{
			my $m = $map{$attr};
			$self->$attr($data->$m());
		}
	}
}




1;