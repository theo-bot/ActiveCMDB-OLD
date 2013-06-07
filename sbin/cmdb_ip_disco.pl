#!/usr/bin/env perl

use v5.16.0;
use ActiveCMDB::Tools::DiscoProcessor;
use ActiveCMDB::Common::Constants;
use sigtrap qw(handler sigHandler INT TERM);
use Getopt::Long;
use Logger;

my $discovery;

END {
	$discovery->process->cleanup();
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

$discovery = ActiveCMDB::Tools::DiscoProcessor->new({ instance => $instance });
#
# Initialize myself
#
$discovery->init({ instance => $instance});
$discovery->processor();

Logger->info("Exitting");
exit;

sub sigHandler
{
	my $signal = shift;
	$discovery->raise_signal($signal);
}