package ActiveCMDB::Object::Compliance::Rule;

=begin nd

    Script: ActiveCMDB::Object::Compliance::Rule.pm
    ___________________________________________________________________________

    Version 1.0

    Copyright (C) 2011-2015 Theo Bot

    http://www.activecmdb.org


    Topic: Purpose

    ActiveCMDB::Object::Compliance::Rule class definition

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
use Try::Tiny;
use Logger;
use Data::Dumper;
use ActiveCMDB::Common::Constants;
use ActiveCMDB::Object::Compliance::Match;

extends 'ActiveCMDB::Object::CmdbObject';

has 'rule_id'		=> (is => 'rw', isa => 'Int');
has 'active'		=> (is => 'rw', isa => 'Int');
has 'set_id'		=> (is => 'rw', isa => 'Int');
has 'regex_start'	=> (is => 'rw', isa => 'Str');
has 'regex_end'		=> (is => 'rw', isa => 'Str');
has 'os_version'	=> (is => 'rw', isa => 'Str');
has 'last_update'	=> (is => 'rw', isa => 'Int');
has 'updated_by'	=> (is => 'rw',	isa => 'Str');
has 'description'	=> (is => 'rw', isa => 'Str');
has 'matches' => (
	traits	=> ['Array'],
	is		=> 'ro',
	isa		=> 'ArrayRef',
	default	=> sub { [] },
	handles => {
		add_match		=> 'push',
		match_count		=> 'count',
		list_matches	=> 'elements'
	}
);

with 'ActiveCMDB::Object::Methods';

my %map = (
	rule_id			=> 'rule_id',
	active			=> 'active',
	set_id			=> 'set_id',
	regex_start		=> 'regex_start',
	regex_end		=> 'regex_end',
	os_version		=> 'os_version',
	last_update		=> 'last_update',
	updated_by		=> 'updated_by',
	description		=> 'description'
);

my $rule_table  = 'ConfigRule';
my $match_table = 'ConfigMatch';

sub get_data
{
	my($self) = @_;
	my $result = false;
	try {
		my $row = $self->schema->resultset($rule_table)->find({ rule_id => $self->rule_id });
		if ( defined($row) )
		{
			$self->populate($row, \%map);
			my $matches = $row->matches();
			while ( my $row1 = $matches->next ) {
				my $match = ActiveCMDB::Object::Compliance::Match->new(match_id => $row1->match_id);
				$match->get_data();
				$self->add_match($match);
			}
			$result = true;
		} else {
			Logger->warn("No data available.");
		}
	} catch {
		Logger->warn("Failed to fetch rule data.");
		Logger->debug($_);
	}
}

sub save
{
	my($self) = @_;
	my $result = false;
	
	try {
		my $data = $self->to_hashref(\%map);
		my $row = $self->schema->resultset($rule_table)->update_or_create( $data );
		if ( ! defined($self->rule_id) ) {
			$self->rule_id( $row->rule_id );
		}
		
		foreach my $match ($self->list_matches)
		{
			$match->rule_id($self->rule_id);
			$match->save();
		}
		
		$result = true;
	} catch {
		Logger->warn("Failed to save match data");
		Logger->debug($_);
	}
	
	return $result;
}

sub delete
{
	my($self) = @_;
	my $result = false;

	if ( defined($self->rule_id) && $self->rule_id > 0 )
	{
		try {
			my $row = $self->schema->resultset($rule_table)->find({ rule_id => $self->rule_id });
			if ( defined($row) ) {
				$row->delete();
			} else {
				Logger->warn("Rule not found to delete");
			}
		} catch {
			Logger->warn("Failed to delete rule");
			Logger->debug($_);
		}
	} else {
		Logger->warn("Undefined rule.");
	}
}

__PACKAGE__->meta->make_immutable;
1;