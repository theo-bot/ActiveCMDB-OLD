#!/usr/bin/env perl

use v5.16.0;
use ActiveCMDB::Tools::ProcessManager;
use ActiveCMDB::Common::Constants;
use sigtrap qw(handler sigHandler INT CHLD ALRM USR2 TERM);

my $instance;

END {
	$instance->process->cleanup();
}

$instance = ActiveCMDB::Tools::ProcessManager->new();



#
# Initialize myself
#
$instance->init();
$instance->manage();

Logger->info("Exitting");
exit;

sub sigHandler
{
	my $signal = shift;
	
	Logger->warn("Incoming saignal $signal");
	
	$instance->raise_signal($signal);
}