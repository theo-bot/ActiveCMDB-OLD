package ActiveCMDB::Object::Journal;

=begin nd

    Script: ActiveCMDB::Object::Journal.pm
    ___________________________________________________________________________

    Version 1.0

    Copyright (C) 2011-2015 Theo Bot

    http://www.activecmdb.org


    Topic: Purpose

    ActiveCMDB::Object::Journal class definition

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

#
# Include required modules 
#
use Moose;
use Try::Tiny;
use DateTime;
use Logger;
use ActiveCMDB::Model::CMDBv1;
use ActiveCMDB::Schema;

has 'device_id'		=> ( is => 'ro', isa => 'Int' );
has 'id'			=> ( is => 'rw', isa => 'Int' );
has 'date'			=> ( is => 'rw', isa => 'DateTime');
has 'user'			=> ( is => 'rw', isa => 'Str|Undef' );
has 'prio'			=> ( is => 'rw', isa => 'Int|Undef' );
has 'data'			=> ( is => 'rw', isa => 'Str|Undef' );

# Schema
has 'schema'		=> (is => 'rw', isa => 'Object', default => sub { ActiveCMDB::Schema->connect(ActiveCMDB::Model::CMDBv1->config()->{connect_info}) } );

my %mapper = (
	id			=> 'journal_id',
	date		=> 'journal_date',
	user		=> 'user',
	prio		=> 'journal_prio',
	data		=> 'journal_data',
	device_id	=> 'device_id'
);

with 'ActiveCMDB::Object::Methods';

sub get_data
{
	my($self) = @_;
	my($row);
	
	if ( $self->device_id && $self->id ) {
		$row = $self->schema->resultset("IpDeviceJournal")->find(
						{
							device_id	=> $self->device_id,
							journal_id	=> $self->id
						}
		);
		if ( defined($row) ) {
			foreach my $key (keys %mapper)
			{
				my $attr = $mapper{$key};
				if ( $row->can($attr) ) { $self->$key($row->$attr) }
			}
		}
	}
}

=item list

Returns an array of available journal_id's for a particular device

=cut

sub list
{
	my($self) = @_;
	my @list = ();
	my($rs);
	
	$rs = $self->schema->resultset("IpDeviceJournal")->search(
			{
				device_id => $self->device_id
			},
			{
				columns => qw/journal_id/,
				order_by => 'journal_date'
			}
	);
	if ( $rs->count > 0 )
	{
		while ( my $row = $rs->next )
		{
			push(@list, $row->journal_id);
		}
	}
	
	return @list;
}

=item store

Store a journal

=cut

sub save {
	my($self) = @_;
	
	
	my $data = $self->to_hashref(\%mapper);
	
	try {
		my $rs = $self->schema->resultset("IpDeviceJournal")->update_or_create( $data );
		if ( ! $rs->in_storage ) {
			$rs->insert;
		}
	} catch {
		Logger->warn("Failed to save journal: " . $_ );
	}
}

1;