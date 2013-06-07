package Methods;

use Config::Settings;
use Data::Dumper;
use Logger;
use Moose::Role;


sub import {
	my($self, $pkg) = @_;
	if ( defined($pkg) ) {
		my $file = sprintf("%s/conf/class/%s.class",$ENV{CMDB_HOME}, $pkg);
		Logger->info("Parsing $file");
		my $config = Config::Settings->new->parse_file($file);
		if ( defined($config->{class}) ) {
			Logger->info("Successfully import $pkg");
				
			return $config->{class};
		} else {
			Logger->warn("Failed to import $pkg");
		}
	} 
}

1;