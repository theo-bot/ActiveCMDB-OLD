#!/usr/bin/env perl

use v5.16.0;
use Term::ReadKey;
use DBI;
use Data::Dumper;
use JSON::XS;
use Cwd;
use strict;
use Log::Log4perl qw(:easy);
use Module::Find;
use Switch;
use Sys::Hostname;

no strict "refs";

#
# Initialize variables
#

my %exec = ();
my @chars = ("A".."Z", "a".."z");
my $string;
$string .= $chars[rand @chars] for 1..8;
$exec{mysql_tmp} = sprintf("%s/%s.cnf",$ENV{HOME}, $string);

#
# Initialize logging
#

Log::Log4perl->easy_init({
	level	=> $DEBUG,
	file	=> ">>" . $ENV{HOME} . "/CMDB_INSTALL.log",
	layout	=> "%d %C %p %m%n"
});

my $logger = Log::Log4perl->get_logger();

#
# Importing plugins
# 
foreach my $mod (findsubmod Plugins) {
	my $stm = sprintf("use $mod;");
	eval $stm;
	if ( $@ ) {
		$logger->fatal("Failed to import module $mod"); 
		die($@); 
	}
	$logger->info("Imported module $mod");
}

#
# Opening plan
#
$logger->info("Opening plan");
my $plan = "../common/cmdb.plan";
if ( -r $plan ) {
	open(FH, "<", $plan);
	$logger->info("Plan opened");
	my $data = do { local($/); <FH> };
	close(FH);
	my $coder = JSON::XS->new->ascii->pretty->allow_nonref;

	$plan = $coder->decode($data);
	$logger->info("Plan decoded");
} else {
	$logger->fatal("Unable to open/decode plan");
	exit;
}

#
# Opening server installation status
#
my $ifolder = $ENV{HOME}.'/.ActiveCMDB';
my $iserver = sprintf("%s/%s.json",$ifolder, GetHostname());
if ( ! -d $ENV{HOME}.'/.ActiveCMDB' ) {
	mkdir $ENV{HOME}.'/.ActiveCMDB';
	chmod(0700, $ENV{HOME}.'/.ActiveCMDB');
}
if ( ! -f $iserver ) {
	open(FH,">", $iserver);
	my $data = undef;
	$data->{last_update} = time();
	my $coder = JSON::XS->new->ascii->pretty->allow_nonref;
	print FH $coder->encode($data);
	close(FH);
} 

if ( -r $iserver )
{
	open(FH, "<", $iserver);
	my $data = do { local($/); <FH> };
	my $coder = JSON::XS->new->ascii->pretty->allow_nonref;
	$iserver = $coder->decode($data);
	close(FH);
}

#
# Executing steps
#

foreach my $step (sort keys %{$plan->{steps}})
{
	my($r,$v);

	if ( defined($iserver->{steps}->{$step}) )
	{
		if ( defined($iserver->{steps}->{$step}->{status}) && $iserver->{steps}->{$step}->{status} == 1  && $iserver->{steps}->{$step}->{repeat} == 0 )
		{
			# Step already processes
			next;
		}
		if ( defined($plan->{steps}->{$step}->{depend}) )
		{
			my $depend = $plan->{steps}->{$step}->{depend};
			if ( defined($iserver->{steps}->{$depend}->{status}) && $iserver->{steps}->{$depend}->{status} == 1 )
			{
				$logger->info("Dependancy $depend completed");
			} else {
				$logger->fatal("Dependancy not completed");
				exit 1;
			}
		}
	} else {
		$iserver->{steps}->{$step} = $plan->{steps}->{$step};
		$iserver->{steps}->{$step}->{status} = 0;
		SaveStatus($iserver);
	}
	
	switch( $plan->{steps}->{$step}->{type} )
	{
		case 1		{ 
						($r,$v) = PerlSub($plan->{steps}->{$step}->{action}, $plan->{steps}->{$step}->{args},$exec{config});
						
					}
		case 2		{ 
						($r,$v) = PerlScript($plan->{steps}->{$step}->{action}, $plan->{steps}->{$step}->{args},$exec{config}); 
					}
		case 3		{ 
						($r,$v) = SqlScript($plan->{steps}->{$step}->{action},$exec{config}); 
					}
	}
	
	if ( $r && defined($plan->{steps}->{$step}->{exec_key}) && defined($v) ) 
	{
		my $k  = $plan->{steps}->{$step}->{exec_key};
		$logger->info("Storing exec key $k");
		$exec{$k} = $v;
	}
	if ( ! $r ) {
		$logger->fatal("Error executing $step, check logs");
	} else {
		$iserver->{steps}->{$step}->{status} = 1;
		SaveStatus($iserver);
	}
	
	print $plan->{steps}->{$step}->{descr},"\n";
}



#
# Common routines
#

sub PerlSub
{
	my($sub, $args,$config) = @_;
	$logger->debug("Arguments: $args");
	my @args = ();
	if ( defined($args) ) {
		@args = split(/\,/,$args);
	}
	$logger->info("Executing routine $sub");
	return &$sub($config, @args);
}

sub PerlScript
{
	my($script, $args) = @_;
	my@args = ();
	if ( defined($args) ) {
		@args = split(/\,/,$args);
	}
	$script =~ s/\$CMDB_HOME/$ENV{CMDB_HOME}/g;
	
	
	my $result = system($script, @args);
	if ( $result == 0 ) { return 1; } else { return 0; }
}

sub SqlScript
{
	my($script) = @_;
	if ( !exists $exec{mysql} )
	{
		print "Enter mysql location [/usr/bin/mysql] ";
		chomp($exec{mysql} = <STDIN>);
		if ( !$exec{mysql} ) { $exec{mysql} = '/usr/bin/mysql'; }
	}
	if ( !exists $exec{mysql_pwd} )
	{
		print "Enter mysql admin password ";
		ReadMode 2;
		chomp($exec{mysql_pwd} = <STDIN> );
		ReadMode 0;
	}
	$logger->info("Creating mysql file ".$exec{mysql_tmp});
	open(my $fh,">", $exec{mysql_tmp});
	chmod(0600, $fh);
	print $fh '[client]'."\n";
	print $fh 'user=root'."\n";
	print $fh 'password='.$exec{mysql_pwd}."\n";
	print $fh 'database='.$exec{config}->section("cmdb::database::dbname");
	close($fh);
	chmod(0400, $exec{mysql_tmp});
	$script = sprintf("%s/setup/sql/%s",$ENV{CMDB_HOME},$script);
	$logger->info("Executing ".$exec{mysql}." with script file $script");
	my $cmd = sprintf("%s --defaults-file=%s < %s", $exec{mysql}, $exec{mysql_tmp}, $script);
	$logger->info("Executing $cmd");
	my $result = system($cmd);
	if ( $result == 0 ) { return 1; } else { return 0; }
}

sub SaveStatus
{
	my($data) = @_;
	my $ifolder = $ENV{HOME}.'/.ActiveCMDB';
	my $iserver = sprintf("%s/%s.json",$ifolder, GetHostname());
	open(FH,">", $iserver);
	$data->{last_update} = time();
	my $coder = JSON::XS->new->ascii->pretty->allow_nonref;
	print FH $coder->encode($data);
	close(FH);
}

sub GetHostname
{
	my $h = hostname();
	$h =~ s/\..*//;
	
	return $h;
}