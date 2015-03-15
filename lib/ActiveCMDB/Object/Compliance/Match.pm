package ActiveCMDB::Object::Compliance::Match;

=begin nd

    Script: ActiveCMDB::Object::Compliance::match.pm
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

extends 'ActiveCMDB::Object::CmdbObject';

has 'match_id'		=> (is => 'rw', isa => 'Int');
has 'rule_id'		=> (is => 'rw', isa => 'Int');
has 'match_data'	=> (is => 'rw', isa => 'Str');
has 'rev'			=> (is => 'rw', isa => 'Bool');

with 'ActiveCMDB::Object::Methods';

my %map = (
	match_id		=> 'match_id',
	rule_id			=> 'rule_id',
	match_data		=> 'line_match',
	rev				=> 'reverse'
);

my $table = 'ConfigMatch';

sub get_data
{
	my($self) = @_;
	
	my $result = false;
	try {
		my $row = $self->schema->resultset($table)->find({ match_id => $self->match_id });
		if ( defined($row) ) {
			$self->populate($row, \%map);
			$result = true;
		} else {
			Logger->warn("Matching data not available");
		}
	} catch {
		Logger->warn("Failed to fetch match data.");
		Logger->debug($_);
	}
	
	return $result;
}

sub save 
{
	my($self) = @_;
	my $result = false;
	
	try {
		my $data = $self->to_hashref(\%map);
		my $row = $self->schema->resultset($table)->update_or_create( $data );
		if ( ! defined($self->match_id) ) {
			$self->match_id( $row->match_id );
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
	
	if ( defined($self->match_id) && $self->match_id > 0 )
	{
		try {
			my $row = $self->schema->resultset($table)->find({ match_id => $self->match_id });
			$row->delete();
			$result = true;
		} catch {
			Logger->warn("Failed to delete match line");
			Logger->debug($_);
		}
	}
	
	return $result;
}
__PACKAGE__->meta->make_immutable;
1;