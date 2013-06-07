#!/usr/bin/env perl

use v5.16.0;
use ActiveCMDB::Tools::ObjectManager;
use ActiveCMDB::Common::Constants;
use sigtrap qw(handler sigHandler INT TERM);
use Getopt::Long;
use Logger;

my $objectmgr;

END {
	$objectmgr->process->cleanup();
	$objectmgr->process->update();
	sleep 1;
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

$objectmgr = ActiveCMDB::Tools::ObjectManager->new();
#
# Initialize myself
#
$objectmgr->init({ instance => $instance});
$objectmgr->manage();

Logger->info("Exitting");
exit;

sub sigHandler
{
	my $signal = shift;
	$objectmgr->raise_signal($signal);
}