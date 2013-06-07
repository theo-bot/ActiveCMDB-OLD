use utf8;
package ActiveCMDB::Tools::Distributor
{
=begin nd

    Script: ActiveCMDB::Tools::Distributor.pm
    ___________________________________________________________________________

    Version 1.0

    Copyright (C) 2012-2013 Theo Bot

    http://www.activecmdb.org


    Topic: Purpose

    ActiveCMDB::Tools::Distributor class definition

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
	
	This is the actual distribution processor
	
	
=cut

use strict;
use warnings;
use Moose;
use Logger;
use Switch;
use DateTime;
use ActiveCMDB::Common;
use ActiveCMDB::Object::Process;
use ActiveCMDB::Object::Device;
use ActiveCMDB::Tools::Common;
use ActiveCMDB::ConfigFactory;
use ActiveCMDB::Common::Broker;
use ActiveCMDB::Common::Constants;
use ActiveCMDB::Common::Tempfile;
use ActiveCMDB::Model::CMDBv1;
use ActiveCMDB::Schema;
use ActiveCMDB::Dist::Loader;
use ActiveCMDB::Object::Distrule;
use JSON::XS;
use Data::Dumper;
use Carp qw(cluck);

with 'ActiveCMDB::Tools::Common';
has 'distrib' 	=> (is => 'rw', isa => 'Hash' );
has 'ruleset'	=> (is => 'rw', isa => 'HashRef' );
has 'rulemap'	=> (is => 'rw', isa => 'HashRef' );
has 'json'		=> (is => 'rw', isa => 'Object' );
has 'messages'	=> (
	is 		=> 'ro',
	traits	=> ['Hash'],
	isa 	=> 'HashRef[Str]',
	default	=> sub { {} },
	handles	=> {
		set_muid	=> 'set',
		get_muid	=> 'get',
		del_muid	=> 'delete',
		num_muid	=> 'count',
		muid_pairs	=> 'kv',
		muid_exists	=> 'exists',
	},
);

has 'cloud' => (
	is => 'rw', 
	isa => 'Object',
);

use constant CMDB_PROCESSTYPE => 'distrib';

no strict 'refs';

sub BUILD {
	my $self = shift;
	$self->cloud( ActiveCMDB::Model::Cloud->new() );
}

sub init {
	my($self, $args) = @_;
	
	Logger->info("Initializing distribution processor");
	$self->{signal_raised} = false;
	$self->config(ActiveCMDB::ConfigFactory->instance());
	$self->config->load('cmdb');
	
	$self->process( ActiveCMDB::Object::Process->new(
			name		=> CMDB_PROCESSTYPE,
			instance	=> $args->{instance},
			server_id	=> $self->config->section('cmdb::default::server_id')
		)
	);
	$self->process->get_data();
	
	$self->process->type(CMDB_PROCESSTYPE);
	$self->process->status(PROC_RUNNING);
	$self->process->pid($$);
	$self->process->ppid(getppid());
	$self->process->path($self->config->section('cmdb::process::' . CMDB_PROCESSTYPE . '::path'));
	$self->process->update($self->process->process_name());
	
	#
	# Create internal JSON Coder
	#
	$self->json( JSON::XS->new->ascii->pretty->allow_nonref );
	
	#
	# Connecting to database
	#
	$self->schema(ActiveCMDB::Model::CMDBv1->instance());
	
	#
	# Connect to broker
	#
	$self->broker(ActiveCMDB::Common::Broker->new( $self->config->section('cmdb::broker') ));
	$self->broker->init({ 
							process   => $self->process,
							subscribe => true
						});
	
	
	#
	# Disconnect fromn tty and start new session
	#
	$self->process->disconnect();
	
	#
	# Import rules
	#
	$self->ruleset($self->RulesLoader());
	$self->rulemap(LoadMap());
	Logger->debug(Dumper($self->ruleset));
}

sub processor
{
	my($self) = @_;
	Logger->info("Start processing loop");
	my($msg, $delay);
	my $timer = time();
	
	while ( $self->process->status != PROC_SHUTDOWN )
	{
		# Reset delay timer
		$delay = 5;
		
		#
		# Handle raised signals
		#
		if ( $self->raise_signal == true ) {
			Logger->debug("Seems a signal has been raised");
			$self->handle_signals();
			$self->raise_signal(false);
			next;
		}
		
		#
		# Check if there is a message at the broker
		#
		$msg = $self->broker->getframe({ process_type => $self->process->type });
		if ( $msg && !$self->muid_exists($msg->muid) ) {
			
			switch ( $msg->subject )
			{
				case 'Shutdown'			{ $self->process->status(PROC_SHUTDOWN) }
				case 'ReloadRules'		{ $self->ruleset(RulesLoader()); }
				case 'UpdateDistRule'	{ $self->update_dist_rule( $msg->payload ); }
				case 'UpdateRuleMap'	{ $self->update_rule_map( $msg->payload ); }
				else					{ $self->process_message($self->ruleset, $msg); }
			}
			$delay--;
			
			Logger->debug("Message processed");
		}
		if ( $msg && $self->muid_exists($msg->muid) ) {
			Logger->info("Discarting message " . $msg->muid );
			$self->del_muid($msg->muid);
		}
		
		if ( time() - $timer > 30 ) {
			$self->update_rule_map();
			$timer = time();
			
			Logger->info("Number of sent messages in admin:" . $self->num_muid );
			$self->cleanup_muid();
		} 
		
		#
		# Make sure we don't start using too much cpu
		#
		if ( $delay > 0 ) {
			$self->process->action("Sleeping");
			$self->process->status(PROC_IDLE);
			$self->process->pid($$);
			$self->process->update($self->process->process_name);
			sleep $delay;
		}
	}	
}

sub process_message
{
   my($ruleset, $msg) = @_;

   my %data = ();

   $data{message} = $msg;
   my $pl = $msg->payload;
   
   my %map = (
           'device' => 'ActiveCMDB::Object::Device'
   );

   #
   # Import data from message
   #     
   foreach (keys %{$pl})
   {
       my $object = $objects_mapper->{$_};
       my $stm = 'use ' . $object . ';';
       eval $stm;
       $data{$_} = $object->new( $pl->{$_} );
       $data{$_}->get_data();
   }

   RULES: foreach my $objrule (sort keys %{$ruleset})
   {
       my $res = true;
       Logger->info($objrule);
       foreach my $rule (keys %{$ruleset->{$objrule}->{rule}})
       {
           next unless ( $rule =~ /^(.+?)\.(.+)$/ );
           my $m = reftype($ruleset->{$objrule}->{rule}->{$rule}) . "_COMPARE";
           if ( $data{$1}->can($2) )
           {
               my $result = &$m($data{$1}->$2(), $ruleset->{$objrule}->{rule}->{$rule});
               if ( ! $result ) {
                   $res = false;
                   Logger->info("\t$rule did not match");
               } else {
                   Logger->info("\t$rule matched");
               }
           } else {
               Logger->warn("Invalid rule $rule condition. $1 does not support method $2");
               last RULES;
           }
       }
       if ( $res ) {
           Logger->info("\tExecuting actions for $objrule");
           foreach my $action (keys %{$ruleset->{$objrule}->{action}})
           {
               process_action($action, $ruleset->{$objrule}->{action}->{$action});
           }
       }
       if ( defined($ruleset->{$objrule}->{continue}) )
       {
           if ( $ruleset->{$objrule}->{continue} eq "whenNotMatched" && $res ) {
               Logger->info("Stop further processing");
               last RULES;
           }
           if ( $ruleset->{$objrule}->{continue} eq "whenMatched" && !$res ) { last RULES; }
           if ( $ruleset->{$objrule}->{continue} eq "Stop" ) { last RULES; }
       } else {
           #print Dumper($ruleset->{$objrule}),"\n";
           Logger->info("No continue rule for $objrule");
       }
   }

}

sub process_action
{
   my($action, $val) = @_;
   my @vals = ();
   if ( reftype($val) eq 'ARRAY' )
   {
       @vals = @{$val};
   } else {
       push(@vals, $val);
   }

   foreach (@vals) {
       Logger->info("\tExecuting action $action with value ".$_);
   }
}

sub ARRAY_COMPARE
{
   my($val, $ds) = @_;;
   Logger->info("Testing $val in Array");
   foreach my $y (@{$ds})
   {
       Logger->debug("Matching $val to $y");
       if ( $val eq $y ) { return true; }
   }
}

sub SCALAR_COMPARE
{
   my($val, $y) = @_;
   if ( $val eq $y ) { return true; }
}

sub handle_signals
{
	my($self) = @_;
	Logger->warn("Handling incoming signal");
	foreach my $sig (keys $self->{signal})
	{
		Logger->debug("Processing signal $sig");
		switch ($sig)
		{
			case 'INT'		{ $self->process->status(PROC_SHUTDOWN); }
			case 'TERM'		{ $self->process->status(PROC_SHUTDOWN); }
		}
	}
}

sub update_dist_rule
{
	my($self, $data) = @_;
	
	Logger->info("Updating distrule " . $data->{name});
	my $newrule = ActiveCMDB::Object::Distrule->new();
	$newrule->from_json( $data );
	
	my $oldrule = ActiveCMDB::Object::Distrule->new();
	$oldrule->name( $newrule->name() );
	$oldrule->get_data();
	
	Logger->info("New serial " . $newrule->serial . " , Old serial " . $oldrule->serial );
	if ( $newrule->serial > $oldrule->serial ) {
		Logger->info("Saving rule");
		$newrule->save();
		$self->ruleset(RulesLoader());
	} else {
		Logger->warn("Invalid serial " . $newrule->serial );
	}
	
	#Logger->debug(Dumper($self->ruleset));
}

sub update_rule_map
{
	my($self, $mapdata) = @_;
	my $map = undef;
	my $savemap = false;
	if ( defined($mapdata) )
	{
		$map = $self->json->decode($mapdata);
		if ( $map->{serial} > $self->rulemap->{serial} ) {
			$self->rulemap($map);
			SaveMap($self->rulemap);
		}
	} else {
		$map = LoadMap();
		if ( $map->{serial} > $self->rulemap->{serial} ) {
			$self->rulemap($map);
			my $message = ActiveCMDB::Object::Message->new();
			$message->from( $self->process->name );
			$message->subject('UpdateRuleMap');
			$message->to($self->config->section("cmdb::process::distrib::exchange"));
			$message->payload($self->json->encode($map));
			Logger->debug("Sending message to " . $message->to );
			$self->broker->sendframe($message,{ priority => PRIO_HIGH } );
			$self->set_muid($message->muid(), time());
		}
	}
}

sub cleanup_muid
{
	my($self) = @_;
	for my $pair ( $self->muid_pairs ) {
		if ( time() - $pair->[1] > 300 ) {
			$self->del_muid($pair->[0]);
		}
	}
}

}
1;