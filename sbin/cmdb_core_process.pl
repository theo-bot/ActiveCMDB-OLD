#!/usr/bin/env perl

=begin nd

    Script: cmdb_core_process.pl
    ___________________________________________________________________________

    Version 1.0

    Copyright (C) 2011-2015 Theo Bot

    http://www.activecmdb.org


    Topic: Purpose

    Process Manager

    About: License

    This program is free software; you can redistribute it and/or
    modify it under the terms of the GNU General Public License
    as published by the Free Software Foundation; either version 2
    of the License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    Topic: Release information

    $Rev$

=cut

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
