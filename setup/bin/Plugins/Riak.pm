package Plugins::Riak;

use Exporter;
use Data::Dumper;
use Log::Log4perl;
use Net::Riak;
use ActiveCMDB::Common::Crypto;
use Try::Tiny;

my $logger = Log::Log4perl->get_logger();
@ISA = ('Exporter');

@EXPORT = qw(
				SetupCloud
			);

sub SetupCloud
{
	my($config) = @_;
	
	try {
		my $client = Net::Riak->new(
			host		=> $config->section("cmdb::cloud::host"),
			ua_timeout	=> $config->section("cmdb::cloud::timeout")
		);
	
		foreach my $bn (qw/cmdbImport cmdbImportLines/)
		{
			my $bucket = $client->bucket($bn);
			$client->setup_indexing($bn);
		}
	} catch {
		$logger->error("Failed to setup riak cloud");
		return 0;
	};
	
	return 1;
}