package ActiveCMDB::Common::Broker;

=head1 MODULE -  AvtiveCMDB::Common::Broker.pm
    ___________________________________________________________________________

=head1 VERSION

    Version 1.0

=head1 COPYRIGHT

    Copyright (C) 2011-2015 Theo Bot

    http://www.activecmdb.org


=head1 DESCRIPTION

    Abstraction Module for Brokers

=head1 LICENSE

    This program is free software; you can redistribute it and/or
    modify it under the terms of the GNU General Public License
    as published by the Free Software Foundation; either version 2
    of the License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

=cut

use ActiveCMDB::ConfigFactory;
use Data::Dumper;

=head1 METHODS

=head2 new

Create a new instance of this class.

=head3 Arguments

 $config - Hash reference with attributes:
 			typeof   - RabbitMQ / ActiveMQ
 			uri      - Connection URI, ie tcp://127.0.0.1:5672
 			user     - Username
 			password - Password
 			pwencr   - Is the password encrypted (0: No, 1: Yes)
 			prefix   - Default prefix for destinations


It does B<not> automatically subscribe to queue's/exchanges

=cut

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

=head2 init

Connect to a broker. If $args->{subscribe} is true then initiate
subscribtions.

 Arguments
 $self - Reference to object
 $args - Hash reference may containt keys like:
           subscribe - 0, Do not initiate subscribtions, 1, Initiate subscriptions
           process   - ActiveCMDB::Object::Process object.

=cut

sub init {
	my($self, $args) = @_;
	
	$self->connect($self->config->section("cmdb::broker"));
	if ( $args->{subscribe} ) {
		$self->cmdb_init($args);
	}
}

=head2 config

Get or Set the broker configurationl

=cut

sub config {
	my($self, $cfg) = @_;
	if ( defined($cfg) ) {
		$self->{config} = $cfg;
	}
	return $self->{config};
}

1;