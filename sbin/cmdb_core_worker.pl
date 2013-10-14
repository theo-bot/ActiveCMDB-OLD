#!/usr/bin/env perl

=begin nd

    Script: cmdb_core_worker.pl
    ___________________________________________________________________________

    Version 1.0

    Copyright (C) 2011-2015 Theo Bot

    http://www.activecmdb.org


    Topic: Purpose

    IP Device Discovery Manager

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
use ActiveCMDB::Tools::Worker;
use ActiveCMDB::Common::Constants;
use ActiveCMDB::Object::Message;
use sigtrap qw(handler sigHandler INT TERM);
use Getopt::Long;
use Logger;

my $worker;

END {
	$worker->process->cleanup();
}
#
# Process arguments
#
our $instance;
our $id;
our $jobtype;
our $job = false;

my $result = GetOptions (
	"instance=i"	=> \$instance,
	"job"			=> \$job,
	"id=s"			=> \$id,
	"type=s"		=> \$jobtype
	);
if ( !defined($instance)) {
	Logger->warn("No instance defined");
	exit 1;
}

$ENV{INSTANCE} = $instance;

$worker = ActiveCMDB::Tools::Worker->new({ instance => $instance });
#
# Initialize myself
#
$worker->init({ instance => $instance});
if ( !$job )
{
	Logger->info("Entering main processing loop");
	$worker->processor();
} else {
	Logger->info("Start processing ");
	my $work = {
		'Type' 	=> $jobtype,
		
	};
	my $msg = ActiveCMDB::Object::Message->new();
	$msg->from('cmdline');
	$msg->payload( $work );
	
	$worker->handle_job($msg);
}
Logger->info("Exitting");
exit;

sub sigHandler
{
	my $signal = shift;
	$worker->raise_signal($signal);
}