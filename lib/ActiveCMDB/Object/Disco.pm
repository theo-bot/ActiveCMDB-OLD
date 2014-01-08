package ActiveCMDB::Object::Disco;

=begin nd

    Script: ActiveCMDB::Object::IpType.pm
    ___________________________________________________________________________

    Version 1.0

    Copyright (C) 2011-2015 Theo Bot

    http://www.activecmdb.org


    Topic: Purpose

    Object class definition for discovery schedules

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

#########################################################################
# Initialize  modules
use Moose;
use Moose::Util::TypeConstraints;
use namespace::clean;
use Try::Tiny;
use DateTime;
use POSIX;
use Logger;
use ActiveCMDB::Common::Constants;

extends 'ActiveCMDB::Object::CmdbObject';

has scheme_id	=> (is => 'rw', isa => 'Int');
has name		=> (is => 'rw', isa => 'Str');
has active		=> (is => 'rw', isa => 'Int', default => 0);
has block1		=> (is => 'rw', isa => 'Str', default => "600;720");
has block2		=> (is => 'rw', isa => 'Str', default => "0;0");

with 'ActiveCMDB::Object::Methods';



my %map = (
	scheme_id	=> 'scheme_id',
	name		=> 'name',
	active		=> 'active',
	block1		=> 'block1',
	block2		=> 'block2'
);

my $table = 'DiscoScheme';

sub get_data
{
	my($self) = @_;
	
	my $result = false;
	if ( defined($self->scheme_id) && $self->scheme_id > 0 )
	{
		try {
			my $row = $self->schema->resultset($table)->find({ scheme_id => $self->scheme_id });
			if ( defined($row) ) {
				$self->populate($row, \%map);
				$result = true;
			}
		} catch {
			Logger->warn("Failed to fetch scheme data.");
			Logger->debug($_);
		};
	}
	
	return $result;
}

sub save 
{
	my ($self) = @_;
	my $result = false;
	
	try {
		my $data = $self->to_hashref(\%map);
		
		my $row = $self->schema->resultset($table)->update_or_create( $data );
		if ( ! defined($self->scheme_id) ) {
			$self->scheme_id( $row->scheme_id );
		}
		$result = true;
	} catch {
		Logger->warn("Failed to save schema.");
		Logger->debug($_);
	};
	
	return $result
}

sub delete
{
	my($self) = @_;
	my $result = false;
	
	if ( defined($self->scheme_id) && $self->scheme_id > 0 )
	{
		try {
			my $row = $self->schema->resultset($table)->find({ scheme_id => $self->scheme_id });
			if ( defined($row) ) {
				$row->delete();
				$result = true;
			} else {
				Logger->warn("Row not found.");
			}
			$result = true;
		} catch {
			Logger->warn("Failed to delete row.");
			Logger->debug($_);
		}
			
	}
	
	return $result;
}

sub is_active
{
	my($self) = @_;
	
	my $active = false;
	my $tz = strftime("%Z", localtime());
	my $dt = DateTime->now();
	$dt->set_time_zone($tz);
	
	my $moment = ( $dt->hour * 60  + $dt->minute );
	foreach my $block ($self->block1, $self->block2)
	{
		if ( defined($block) && $block =~ /^(\d+);(\d+)$/ )
		{
			if ( $block >= $1 && $block <= $2 ) { $active = true; }
		}
	}
	
	return $active;
}

sub block2str
{
	my($self,$block) = @_;
	my $str = '';
	if ( defined($block) )
	{
		if ( $self->$block() =~ /^(\d+);(\d+)$/ )
		{
			$str .= sprintf("%02d:%02d - %02d:%02d", $1 / 60, $1 % 60, $2 / 60, $2 % 60)
		}
	}
	
	return $str;
}

sub block2part
{
	my($self,$block, $part) = @_;
	my $str;
	if ( defined($block) )
	{
		if ( $self->$block() =~ /^(\d+);(\d+)$/ )
		{
			if ( $part eq 'start') { $str = $1; }
			if ( $part eq 'end') { $str = $2; }
		}
	}
	
	return $str;
}

