package ActiveCMDB::Common::Broker;

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