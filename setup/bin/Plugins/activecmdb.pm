package Plugins::activecmdb;

use Exporter;
use Data::Dumper;
use Log::Log4perl;
use ActiveCMDB::Common::Crypto;
my $logger = Log::Log4perl->get_logger();
@ISA = ('Exporter');

@EXPORT = qw(
	CheckEnv
	CheckConfig
	PrepareDB
);

sub CheckEnv
{
	$logger->info("Checking enviroment");
	if ( !defined($ENV{CMDB_HOME}) ) {
		$logger->error("CMDB_HOME enviroment variable not set");
		return 0;
	}
	if ( ! -d $ENV{CMDB_HOME} ) {
		$logger->error("Enviroment variable CMDB_HOME does not point towards a directory");
		return 0;
	}
	if ( !defined($ENV{PERL5LIB}) ) {
		$logger->error("PERL5LIB enviroment variable not set.");
		return 0;
	}
	if ( $ENV{PERL5LIB} ne $ENV{CMDB_HOME}.'/lib') {
		$logger->error("PERL5LIB variable does not contain ActiveCMDB library path");
		return 0;
	}
	
	$logger->info("Enviroment complies");
	return 1;
}

sub CheckConfig
{
	$logger->info("Checking configuration");
	use ActiveCMDB::ConfigFactory;
	my $config = ActiveCMDB::ConfigFactory->instance();
	$config->load('cmdb');
	
	return (1,$config);
	return 1;
}

sub PrepareDB
{
	my($config, $source) = @_;
	my $dbname = $config->section("cmdb::database::dbname");
	my $dbuser = $config->section("cmdb::database::dbuser");
	my $dbpass = $config->section("cmdb::database::dbpass");
	if ( $config->section("cmdb::database::pwencr") == 1 ) {
		$dbpass = cmdb_decrypt("activecmdb", $dbpass);
	} 
	$logger->debug("Setting database name to $dbname");
	#print Dumper(@_),"\n";
	my $source = sprintf("%s/setup/sql/%s", $ENV{CMDB_HOME}, $source);
	my $dest = $source;
	$dest =~ s/\.sql/\.ddl/;
	open(IN, "<", $source) or die("Unable to open source file $source");
	open(OUT, ">", $dest) or die("Unable to open dest ddl file $dest");
	while ( <IN> )
	{
		s/\[DBNAME\]/$dbname/g;
		s/\[DBUSER\]/$dbuser/;
		s/\[DBPASS\]/$dbpass/;
		print OUT $_;
	}
	close(IN);
	close(OUT);
	exit;
}