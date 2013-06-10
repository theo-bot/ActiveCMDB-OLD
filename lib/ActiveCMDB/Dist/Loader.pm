package ActiveCMDB::Dist::Loader;

=begin nd

    Script: ActiveCMDB::Dist::Loader.pm
    ___________________________________________________________________________

    Version 1.0

    Copyright (C) 2012-2013 Theo Bot

    http://www.activecmdb.org


    Topic: Purpose

    Distribution Manager support library

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

	Topic: Description
	
	This module performs actions on the conversions table
	
	
=cut

use Exporter;
use Config::JSON;
use File::Slurp;
use File::Temp;
use JSON::XS;
use Try::Tiny;
use Data::Dumper;
use Logger;
use ActiveCMDB::Common::Constants;
use ActiveCMDB::Model::Cloud;
use Moose::Role;

our @ISA = ('Exporter');

our @EXPORT = qw(
	RulesLoader
	RulesList
	GetRule
	LoadMap
	SaveMap
	get_rules_dir
	get_map_file
);

my $coder = JSON::XS->new->ascii->pretty->allow_nonref;

sub RulesLoader
{
	my($self) = @_;
	my $map = LoadMap();
	my $config = ActiveCMDB::ConfigFactory->instance();
	
	my $ruleset = undef;
	try {
		my $tmp = ActiveCMDB::Common::Tempfile->new(
								template => 'CmdbXXXXX',
								path      => $ENV{CMDB_HOME} . '/var/tmp',
								suffix   => '.rule' 
							  );
		
		my $cloud = ActiveCMDB::Model::Cloud->new();
		my $bucket = $config->section('cmdb::process::distrib::buckets::rules');
		my $coder = JSON::XS->new->ascii->pretty->allow_nonref;
		
		foreach my $rule_key ( @{$cloud->bucket( $bucket )->get_keys()} )
		{
			Logger->info("Importing rule " . $rule_key);
			my $config = $cloud->get( { key => $rule_key } )->data();
			$tmp->create();
			my $fh = $tmp->open(">");
			print $fh $coder->encode($config);
			
			$fh->close();
			$config = Config::JSON->new($tmp->filename);
			
			next unless ( $config->get('active') );
			Logger->info("Adding rule " . $config->get("name"));
			my $rn = $config->get("priority") . $config->get("name");
			$ruleset = MergeRule($config, $ruleset, $rn, $map);
			#if ( defined($config->get("includes")) )
			#{
			#	foreach my $c ( @{$config->includes()} )
			#	{
			#		$ruleset = MergeRule($c, $ruleset, $rn,$map);
			#	}
			#}
			
			#if ( defined($config->get("continue")) ) {
       		#	$ruleset->{$rn}->{continue} = $config->get("continue");
   			#}
		}
	} catch {
		Logger->fatal("Failed to import rules.\n" . $_ );
	};
	
	return $ruleset;
}

sub LoadMap
{
	Logger->info("Loading map");
	my $map = undef;
	
	my $file = get_map_file();
	
	try {
		my $data = read_file( $file );
		$map = $coder->decode( $data );
	} catch {
		Logger->fatal("Failed to open rulemap.dat " . $_);
		exit 1;
	};
	
	return $map;
}

sub SaveMap
{
	my($map) = @_;
	my $file = get_map_file();
	
	try {
		my $data = $coder->encode( $map );
		write_file( $file, $data );
	} catch {
		Logger->fatal("Failed to save rulemap.dat " . $_ );
		exit 1;
	}
	
	return true;
}

sub MergeRule
{
	my($cfg, $rs, $n, $map) = @_;
	
	foreach my $set (qw/rule action/)
	{
		if ( defined($cfg->get($set)) )
		{
			my $r = $cfg->get($set);
			
			foreach (keys %{$r} )
			{
				if ( defined($map->{map}->{$_}) && checktype($_, $r->{$_}, $map->{map}->{$_}) )
				{
					if ( defined($rs->{$n}->{$set}->{$_}) && reftype($rs->{$n}->{$set}->{$_}) eq 'ARRAY' )
					{
						if ( reftype($r->{$_}) eq 'ARRAY' )
						{
							push(@{$rs->{$n}->{$set}->{$_}}, @{$r->{$_}});
						} else {
							push(@{$rs->{$n}->{$set}->{$_}}, $r->{$_});
						}
					} else {
						$rs->{$n}->{$set}->{$_} = $r->{$_};
					}
					Logger->info("Loaded $set $_");
				} else {
					
					Logger->warn("Syntax error in rule file $_, ignoring rule");
					if ( !defined($map->{map}->{$_}) ) {
						Logger->info($_ . " not defined in rulemap ");
					} else {
						Logger->info("Unmatched reftype");
					}
					Logger->debug(Dumper($map));
					return;
				}
			}
		}
	}
	
	return $rs;
}

sub reftype {
	return ref $_[0] ? ref $_[0] : 'SCALAR';
}

sub checktype {
	my($verb, $data, $mapdata) = @_;
	my $r = reftype($data);
	if ( $mapdata->{reftype} =~ /$r/ ) 
	{ 
		return true; 
	} else {
		print $verb,"\t",reftype($data),"\t",$mapdata->{reftype},"\n";
		return false;
	}
}

sub RulesList 
{
	my @rules = ();
	my $config = ActiveCMDB::ConfigFactory->instance();
	
	my $cloud = ActiveCMDB::Model::Cloud->new();
	my $bucket = $config->section('cmdb::process::distrib::buckets::rules');
	$cloud->bucket( $bucket );
	foreach my $name ( @{ $cloud->bucket( $bucket )->get_keys() }
	 )
	{
		Logger->debug("Processing $name");
		
		my $rule = ActiveCMDB::Object::Distrule->new( name => $name);
		$rule->get_data();

		my $rule_nrules = scalar(keys %{$rule->rule});
		my $rule_nactions = scalar(keys %{$rule->action});
		push(@rules, { 
						rule_file		=> $rule->name,
						rule_name		=> $rule->name,
						rule_active		=> $rule->active,
						rule_priority	=> $rule->priority,
						rule_nrules		=> $rule_nrules,
						rule_nactions	=> $rule_nactions
					}
				);
	}
	
	return @rules;
}

sub GetRule {
	my($rule) = @_;
	my $rules_dir = get_rules_dir();
	try {
		my $data = Config::JSON->new($rules_dir . '/' . $rule)->{config};
		Logger->debug(Dumper($data));
		foreach my $x (keys %{$data->{rule}}) {
			if ( ref($data->{rule}->{$x}) eq 'ARRAY' ) {
				$data->{rule}->{$x} = join(',', @{$data->{rule}->{$x}});
			}
		}
		
		foreach my $x (keys %{$data->{action}}) {
			if ( ref($data->{action}->{$x}) eq 'ARRAY' ) {
				Logger->debug("x => $x");
				$data->{action}->{$x} = join(',', @{$data->{action}->{$x}});
			}
		}
		
		return $data;
	} catch {
		Logger->warn("Failed to fetch rule data for $rule");
	}
}

sub get_rules_dir {
	return sprintf("%s/conf/dist", $ENV{CMDB_HOME});
}

sub get_map_file {
	return sprintf("%s/rulemap.dat", get_rules_dir());
}

1;