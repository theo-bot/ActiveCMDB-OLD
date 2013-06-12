package ActiveCMDB::Controller::Distrule;

=begin nd

    Script: ActiveCMDB::Controller::Distrule.pm
    ___________________________________________________________________________

    Version 1.0

    Copyright (C) 2011-2015 Theo Bot

    http://www.activecmdb.org


    Topic: Purpose

    Catalyst Controller for Distribution Rules

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

use Moose;
use namespace::autoclean;
use Data::Dumper;
use Config::JSON;
use JSON::XS;
use Try::Tiny;
use ActiveCMDB::Common::Constants;
use ActiveCMDB::Dist::Loader;
use ActiveCMDB::Object::Distrule;

BEGIN { extends 'Catalyst::Controller'; }

my $config = ActiveCMDB::ConfigFactory->instance();
$config->load('cmdb');


sub index :Private {
    my ( $self, $c ) = @_;

	$c->stash->{template} = 'distrib/rule_container.tt';
   
}

sub api: Local {
	my($self, $c) = @_;
	
	if ( defined($c->request->params->{oper}) ) {
		$c->forward('/distrule/' . $c->request->params->{oper});
	}
}

sub list :Local {
	my($self, $c) = @_;
	my @rows = ();
	
	my @rules = RulesList();
	
	foreach my $rule (@rules) {
		push(@rows, { id => $rule->{rule_file}, cell=> [
														$rule->{rule_name},
														$rule->{rule_active},
														$rule->{rule_priority},
														$rule->{rule_nrules},
														$rule->{rule_nactions}
													]
						}
			);
	}
	
	my $json->{rows} = [ @rows ];
	$c->log->debug(Dumper(@rules));
	$c->stash->{json} = $json;
	$c->forward( $c->view('JSON') );
}

sub edit :Local {
	my($self, $c) = @_;
	
	if ( defined($c->request->params->{id}) )
	{
		my $rule = ActiveCMDB::Object::Distrule->new(name => $c->request->params->{id} );
		$rule->get_data();
		$c->stash->{rule} = $rule;
	}
	
	$c->stash->{template} = 'distrib/rule_edit.tt';
}


sub save :Local {
	my($self, $c) = @_;

	my $rule = ActiveCMDB::Object::Distrule->new();
	$rule->populate($c->request->params);
	$c->log->info("Old serial " . $rule->serial );
	$rule->serial( $rule->serial + 1 );
	$c->log->info("Serial set to " . $rule->serial);
	#
	# Don't save the rule in the controller but distribute to all 
	# distrib processes, via the exchange
	#
	my $broker = ActiveCMDB::Common::Broker->new( $config->section('cmdb::broker') );

	$broker->init({ process => 'web'.$$ , subscribe => false });
	my $message = ActiveCMDB::Object::Message->new();
	$message->from('web'.$$ );
	$message->subject('UpdateDistRule');
	$message->to($config->section("cmdb::process::distrib::exchange"));
	$message->payload($rule->to_json());
	$c->log->debug("Sending message to " . $message->to );
	$broker->sendframe($message,{ priority => PRIO_HIGH } );
	
	
	$c->response->body('Done');
	$c->response->status(200);
}

sub find_by_ruleopr :Local {
	my($self, $c) = @_;
	my @json = ();
	my $searchStr = $c->request->params->{name_startsWith};
	my $maxRows   = $c->request->params->{maxRows};
	my $mapfile	  = sprintf("%s/conf/dist/rulemap.dat", $ENV{CMDB_HOME});
	
	try {
		my $map = LoadMap();
		foreach my $key (keys %{$map->{map}})
		{
			next unless ( $map->{map}->{$key}->{objtype} eq 'rule' );
			if ( $key =~ /^$searchStr/ ) {
				push(@json, { id => $key, label => $key });
			}
		}
	} catch {
		$c->log->warn("Failed to load rule operators");
	};
	
	#$c->log->debug(Dumper(@json));
	
	$c->stash->{json} = { names => \@json };
	$c->forward( $c->view('JSON') );
}

sub find_by_actionopr :Local {
	my($self, $c) = @_;
	my @json = ();
	my $searchStr = $c->request->params->{name_startsWith};
	my $maxRows   = $c->request->params->{maxRows};
	my $mapfile	  = sprintf("%s/conf/dist/rulemap.dat", $ENV{CMDB_HOME});
	
	try {
		my $map = LoadMap();
		foreach my $key (keys %{$map->{map}})
		{
			next unless ( $map->{map}->{$key}->{objtype} eq 'action' );
			if ( $key =~ /^$searchStr/ ) {
				push(@json, { id => $key, label => $key });
			}
		}
	} catch {
		$c->log->warn("Failed to load rule operators");
	};
	
	#$c->log->debug(Dumper(@json));
	
	$c->stash->{json} = { names => \@json };
	$c->forward( $c->view('JSON') );
}
=head1 AUTHOR

Theo Bot

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
