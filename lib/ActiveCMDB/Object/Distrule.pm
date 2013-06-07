package ActiveCMDB::Object::Distrule;

=begin nd

    Script: ActiveCMDB::Object::Distrule.pm
    ___________________________________________________________________________

    Version 1.0

    Copyright (C) 2012-2013 Theo Bot

    http://www.activecmdb.org


    Topic: Purpose

    ActiveCMDB::Object::Endpoint class definition

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

use Moose;
use strict;
use warnings;
use Try::Tiny;
use Logger;
use Data::Dumper;
use ActiveCMDB::Model::Cloud;
use ActiveCMDB::Dist::Loader;

use constant BUCKETNAME => 'CmdbDistRules';

has	'priority'	=> (is => 'rw', isa => 'Str');
has 'name'		=> (is => 'rw', isa => 'Str');
has 'active'	=> (is => 'rw', isa => 'Int', default => 0);
has 'action'	=> (is => 'rw', isa => 'HashRef|Undef');
has 'rule'		=> (is => 'rw', isa => 'HashRef|Undef');
has 'serial'	=> (
						traits	=> [ 'Counter' ],
						is		=> 'rw', 
						isa		=> 'Num', 
						default => 1,
						handles => {
							inc_serial		=> 'inc',
							dec_serial		=> 'dec',
							reset_serial	=> 'reset'
						}
					);
					
has 'riak' => (
	is => 'rw', 
	isa => 'Object', 
);

sub BUILD {
	my $self = shift;
	Logger->debug("Creating new Distrule object");
	$self->riak ( ActiveCMDB::Model::Cloud->new() );
	$self->riak->bucket( BUCKETNAME );
}

with 'ActiveCMDB::Dist::Loader';

my $coder = JSON::XS->new->ascii->pretty->allow_nonref;

sub get_data {
	my($self) = @_;
	
	if ( defined($self->name) ) {
		
		try {
			my $object = $self->riak->get({ key => $self->name });
			if ( $object->exists == 1 )
			{
				my $data = $object->data;
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
				$self->priority($data->{priority});
				$self->active($data->{active});
				$self->action($data->{action});
				$self->rule($data->{rule});
				$self->serial($data->{serial});
				return $self;
			}
		} catch {
			Logger->warn("Failed to fetch rule data for ". $self->name . "\n" . $_);
		}
	}
}

sub save {
	my($self) = @_;
	
	my $data = $self->to_json();
	Logger->info("Saving rule " . $self->name );
	try {
		my $cloud = ActiveCMDB::Model::Cloud->new();
		$cloud->bucket( BUCKETNAME );
		my $object = $cloud->get({ key => $self->name });
		if ( $object->exists == 1 )
		{
			$cloud->update( { key => $self->name, value => $data }  );
			Logger->info("Object updated");
		} else {
			$cloud->create( { key => $self->name, value => $data } );
			Logger->info("Object created");
		}
		
	} catch {
		Logger->warn("Failed to save rule. ". $_);
	}
}

sub to_json {
	my($self) = @_;
	my $data = undef;
	Logger->debug("Encoding rule to JSON");
	my $rulemap = LoadMap();
	
	foreach my $key (__PACKAGE__->meta->get_all_attributes )
	{
		my $attr = $key->name;
		next if ( $attr =~ /riak/ );
		$data->{$attr} = $self->$attr;
		if ( $attr =~ /rule|action/ ) 
		{
			foreach my $x (keys %{$data->{$attr}} )
			{
				if ( $rulemap->{map}->{$x}->{reftype} eq 'ARRAY' && reftype($data->{$attr}->{$x}) ne 'ARRAY' )
				{
					my $y = $data->{$attr}->{$x};
					$data->{$attr}->{$x} = undef;
					@{ $data->{$attr}->{$x} } = split(/\,/, $y);
				}
			}
		}
	}
	
	Logger->debug("Encoding done");
	$coder->encode( $data );
}

sub from_json {
	my($self, $data) = @_;
	my $rulemap = LoadMap();
	
	Logger->debug("Decoding rule data");
	Logger->debug(Dumper($data));
	my $ref = $coder->decode( $data );
	print Dumper($ref);
	
	foreach my $key (__PACKAGE__->meta->get_all_attributes )
	{
		my $attr = $key->name;
		next if ( $attr =~ /riak/ );
		Logger->debug("Populating $attr from json");
		#if (  )
		$self->$attr( $ref->{$attr} );
	}
	
	
	return $self;
}

sub populate {
	my($self, $params) = @_;
	
	my @action_operator;
	my @action_value;
	my @rule_operator;
	my @rule_value;
	
	if ( ref($params->{action_operator}) eq 'ARRAY' ) {
		@action_operator = @{$params->{action_operator}};
		@action_value	 = @{$params->{action_value}};
	} else {
		push(@action_operator, $params->{action_operator});
		push(@action_value,    $params->{action_value});
	}
	if ( ref($params->{rule_operator}) eq 'ARRAY' ) {
		@rule_operator = @{$params->{rule_operator}};
		@rule_value	   = @{$params->{rule_value}};
	} else {
		push(@rule_operator, $params->{rule_operator});
		push(@rule_value,    $params->{rule_value});
	}
	my $data = undef;
	$self->name($params->{rule_name});
	$self->priority(sprintf("%02d", $params->{rule_priority}));
	$self->active($params->{rule_active} ? 1 : 0);
	my $map = $self->LoadMap();
	for (my $i=0; $i<=scalar(@rule_operator); $i++) {
		next unless ( defined($rule_operator[$i]) && defined($rule_value[$i]) );
		if ( $map->{map}->{$rule_operator[$i]}->{reftype} eq 'SCALAR' )
		{
			$data->{rule}->{$rule_operator[$i]} = $rule_value[$i];
		} else {
			@{$data->{rule}->{$rule_operator[$i]}} = split(/\,/, $rule_value[$i])
		}
	}
	for (my $i=0; $i<=scalar(@action_operator); $i++) {
		next unless ( defined($action_operator[$i]) && defined($action_value[$i]));
		if ( $map->{map}->{$rule_operator[$i]}->{reftype} eq 'SCALAR' ) 
		{
			$data->{action}->{$action_operator[$i]} = $action_value[$i];
		} else {
			@{$data->{action}->{$action_operator[$i]}} = split(/\,/, $action_value[$i]);
		}
	}
	$self->rule($data->{rule});
	$self->action($data->{action});
	$self->serial($params->{serial});
}

__PACKAGE__->meta->make_immutable;
1;