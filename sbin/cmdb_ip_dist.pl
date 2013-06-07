#!/usr/bin/env perl

use v5.16.0;
use ActiveCMDB::Tools::Distributor;
use ActiveCMDB::Common::Constants;
use sigtrap qw(handler sigHandler INT TERM);
use Getopt::Long;
use Logger;

my $distributor;

END {
	$distributor->process->cleanup();
}

#
# Process arguments
#
our $instance;
my $result = GetOptions ("instance=i" => \$instance);
if ( !defined($instance) ) {
	Logger->warn("No instance defined");
	exit 1;
}
$ENV{INSTANCE} = $instance;

$distributor = ActiveCMDB::Tools::Distributor->new({ instance => $instance });
#
# Initialize myself
#
$distributor->init({ instance => $instance});
$distributor->processor();

Logger->info("Exitting");
exit;

sub sigHandler
{
	my $signal = shift;
	$distributor->raise_signal($signal);
}