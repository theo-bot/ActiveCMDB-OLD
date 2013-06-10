package ActiveCMDB::Common::Broker;

=begin nd

    Script: AvtiveCMDB::Common::Broker.pm
    ___________________________________________________________________________

    Version 1.0

    Copyright (C) 2012-2013 Theo Bot

    http://www.activecmdb.org


    Topic: Purpose

    Abstraction Module for Brokers

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

use ActiveCMDB::ConfigFactory;
use Data::Dumper;

sub new {
	my($class, $config) = @_;
	
	my $self = undef;
	$self->{mq} = undef;
	$self->{timeout} = 90;
	
	bless $self, $class;
	
	$self->config(ActiveCMDB::ConfigFactory->instance());
	$self->config->load('cmdb');
	Logger->debug(Dumper($config));
	my $module = sprintf("ActiveCMDB::Common::Broker::%s", $config->{typeof} );
	my $cmd = sprintf("use base %s;", $module);
	eval $cmd;
	if ( !$@ ) {
		unshift(@ISA, $module);
	} else {
		print "Unable to include ".$config->{typeof} . "\n" . $@ . "\n";
	}
	
	@{ $self->{queues} } = ();
	@{ $self->{xchngs} } = ();
	
	return $self;
}

sub init {
	my($self, $args) = @_;
	
	$self->connect($self->config->section("cmdb::broker"));
	if ( $args->{subscribe} ) {
		$self->cmdb_init($args);
	}
}

sub config {
	my($self, $cfg) = @_;
	if ( defined($cfg) ) {
		$self->{config} = $cfg;
	}
	return $self->{config};
}
1;