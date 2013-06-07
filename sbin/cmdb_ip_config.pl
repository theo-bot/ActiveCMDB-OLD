#!/usr/bin/env perl

use v5.16.0;
use ActiveCMDB::Tools::ConfigFetcher;
use sigtrap qw(handler sigHandler INT TERM);
use Getopt::Long;
use Logger;


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

my $fetcher = ActiveCMDB::Tools::ConfigFetcher->new({ instance => $instance });
#
# Initialize myself
#
$fetcher->init({ instance => $instance});
$fetcher->process();

exit;

sub sigHandler
{
	my $signal = shift;
	$fetcher->raise_signal($signal);
}