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
no strict "refs";
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
	my $coder = JSON::XS->new->ascii->pretty->allow_nonref;

	$plan = $coder->decode($data);
	$logger->info("Plan decoded");
} else {
	$logger->fatal("Unable to open/decode plan");
	exit;
}

#
# Executing steps
#

foreach my $step (sort keys %{$plan->{steps}})
{
	my($r,$v);
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
	print "@args\n";
	return &$sub($config, @args);
}

sub PerlScript
{
	my($script, $args) = @_;
	my@args = ();
	if ( defined($args) ) {
		@args = split(/\,/,$args);
	}
	
	return system($script, @args);
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
	close($fh);
	chmod(0400, $exec{mysql_tmp});
	$script = sprintf("%s/setup/sql/%s",$ENV{CMDB_HOME},$script);
	$logger->info("Executing ".$exec{mysql}." with script file $script");
	my $cmd = sprintf("%s --defaults-file=%s < %s", $exec{mysql}, $exec{mysql_tmp}, $script);
	$logger->info("Executing $cmd");
	my $result = system($cmd);
	
}