package ActiveCMDB::Tools::Common;

=begin nd

    Script: ActiveCMDB::Tools::Common.pm
    ___________________________________________________________________________

    Version 1.0

    Copyright (C) 2011-2015 Theo Bot

    http://www.activecmdb.org


    Topic: Purpose

    ActiveCMDB::Tools::Common class definition

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
	
	Common methods for all tools classes
	
	
=cut

use strict;
use ActiveCMDB::Common::Constants;
use Logger;
use Data::UUID;
use Net::DNS;
use Moose::Role;

has 'config'		=> ( is => 'rw', isa => 'Object' );
has 'schema'		=> ( is => 'rw', isa => 'Object' );
has 'broker'		=> ( is => 'rw', isa => 'Object' );		
has 'process'		=> (is => 'rw', isa => 'Object');

sub instance {
	my($self) = @_;
	
	return $self->process->instance;
}

sub raise_signal {
	my($self, $signal) = @_;
	
	if ( defined($signal) ) {
		$self->{signal_raised} = true;
		$self->{signal}->{$signal} = true;
	}
	
	return $self->{signal_raised};
}

sub reset_signal {
	my($self) = @_;
	$self->{signal_raised} = false;
	
	return $self->{signal_raised};
}

sub uuid {
	my($self) = @_;
	
	if ( !defined($self->{uuid_generator}) ) {
		$self->{uuid_generator} = new Data::UUID;
	}
	
	return $self->{uuid_generator}->create_str();
}

sub get_class_by_oid {
	my($self, $sysoid) = @_;
	my($class, $score);
	$score = 0;
	
	foreach my $oid (keys %{$self->{oid2class}})
	{
		my $oid_len = length($oid);
		my $test    = $oid;
		$test =~ s/\./\\\./g;
		
		Logger->debug("Matching $sysoid to $test");
		if ( $sysoid =~ /$test/ && $oid_len > $score ) {
			$class = $self->{oid2class}->{$oid};
			$score = $oid_len;
 		} else {
 			Logger->debug("No match");
 		}
	}
	Logger->info("SysObjectID matched to class $class with a score of $score");
	return $class;
}

sub class_loader {
	my($self) = @_;
	my($module_directory, $result, $file);
	
	$self->{oid2class} = undef;
	$self->{classes} = undef;
	
	$module_directory = sprintf("%s/lib/Class", $ENV{CMDB_HOME});
	$result = opendir(DIR, $module_directory);
	if ( !$result ) {
		Logger->fatal("Unable to open module directory");
		exit 1;
	}
	while ( defined($file = readdir(DIR)) )
	{
		next unless $file =~ /.+\.pm$/;
		Logger->debug("Processing file $file");
		
		my $class_name	= "Class::" . $file;
		my $pkg   		= $file;
		$class_name		=~ s/\.pm$//;
		$pkg			=~ s/\.pm$//;
		
		eval "use $class_name;";
		if ( $@ ) {
			Logger->warn("Failed to load $class_name : " . $@ );
		} else {
			Logger->debug("Creating instance of $class_name");
			my $class = $class_name->new();
			Logger->debug("Start importing $pkg");
			my $set = $class->import($pkg);
			
			if ( defined($set->{$pkg}) ) {
				$self->{classes}->{$class_name} = $set->{$pkg};
				
				foreach my $oid (@{$set->{$pkg}->{oidset}})
				{
					$self->{oid2class}->{$oid} = $class_name;
				}
				Logger->info("Imported $class");
			} else {
				Logger->warn("Failed to import class $class_name");
			}
		}
		Logger->debug("Done $file")
	}
	closedir(DIR);
	
}

sub lookup
{
	my($self, $name) = @_;
	my $resolver = Net::DNS::Resolver->new();
	my @addrs = ();
	
	my $query = $resolver->search($name);
	
	if ($query) {
    	foreach my $rr ($query->answer) {
			next unless $rr->type eq "A";
			push(@addrs, $rr->address);
		}
 	} else {
		Logger->warn("query failed: " . $resolver->errorstring);
	}
	
	return @addrs;
}

1;