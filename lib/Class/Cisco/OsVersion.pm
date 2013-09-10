package Class::Cisco::OsVersion;
use v5.16.0;
use Moose::Role;

sub discover_osversion
{
	my ($self, $data) = @_;
	
	my $sysdesc = $self->attr->sysdescr;
	if ( $sysdesc =~ /IOS/ )
	{
		$self->attr->os_type('IOS');
		if ( $sysdesc =~ /Version (.+?),/ ) {
			$self->attr->os_version($1);
		}
	} 
};
	
sub save_osversion
{
	my($self) = @_;
	$self->attr->save();
};

1;