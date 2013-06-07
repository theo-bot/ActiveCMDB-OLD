package Class::Device::Icmp;

use Moose::Role;
use Switch;
use ActiveCMDB::Common::Constants;
use Logger;

sub ping 
{
	my($self) = @_;
	my($command);
	
	if ( -e '/etc/redhat-release' || -e '/etc/SuSe-release' ) 
	{
		$command = '/bin/ping -c 3 -s 56 ' . $self->attr->mgtaddress;
		 
	} 
	
	return $self->_command($command);
}

sub _command {
	my($self, $command) = @_;
	my($result);
	
	if ( defined($command) ) {
		$command .= " 1>/dev/null 2>&1";
		Logger->debug("$command");
		$result = system($command);
		$result = $result ? 0 : 1;
	}
	
	return $result;
}

1;