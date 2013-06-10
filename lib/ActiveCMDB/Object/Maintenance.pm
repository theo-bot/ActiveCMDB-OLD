package ActiveCMDB::Object::Maintenance;

=begin nd

    Script: ActiveCMDB::Object::Maintenance.pm
    ___________________________________________________________________________

    Version 1.0

    Copyright (C) 2012-2013 Theo Bot

    http://www.activecmdb.org


    Topic: Purpose

    Maintenance Object class definition

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
use Try::Tiny;
use Logger;
use DateTime;
use ActiveCMDB::Common::Constants;
use Data::Dumper;

has 'maint_id'		=> (is => 'ro', isa => 'Int');
has 'descr'			=> (is => 'rw', isa => 'Str');
has 'start_date'	=> (is => 'rw', isa => 'Int|Undef', default => 0);
has 'end_date'		=> (is => 'rw', isa => 'Int|Undef', default => 0 );
has 'start_time'	=> (is => 'rw', isa => 'Int|Undef', writer => '_start_time', default => 0);
has 'end_time'		=> (is => 'rw', isa => 'Int|Undef', writer => '_end_time', default => 0);
has 'm_repeat'		=> (is => 'rw', isa => 'Int', default => 0);
has 'm_interval'		=> (is => 'rw', isa => 'Int', default => 0);

has 'schema'		=> (is => 'rw', isa => 'Object', default => sub { ActiveCMDB::Schema->connect(ActiveCMDB::Model::CMDBv1->config()->{connect_info}) } );

sub get_data
{
	my($self) = @_;
	my($row);
	if ( defined($self->maint_id) )
	{
		$row = $self->schema->resultset("Maintenance")->find({ maint_id => $self->maint_id } );
		if ( defined($row) )
		{
			foreach my $key ( __PACKAGE__->meta->get_all_attributes )
			{
				my $attr = $key->name;
				next if ( $attr =~ /maint_id|schema/ );
				if ( $row->can($attr) && defined($row->$attr) ) {
					if ( $attr =~ /end_time|start_time/ ) {
						my $m = 'set_'.$attr;
						$self->$m($row->$attr);	
					} else {
						$self->$attr($row->$attr);
					}
				}
			}
		}
	}
}

sub save 
{
	my($self) = @_;
	
	my @colums = ();
	my($rs, $data, $attr);
	
	# Save ip_device table data, which is in IpDevice
	@colums = $self->schema->source("Maintenance")->columns;
	$data = undef;
	
	foreach $attr (@colums)
	{
		$data->{$attr} = $self->$attr;
	}
	
	Logger->debug(Dumper($data));
	
	try {
		$rs = $self->schema->resultset("Maintenance")->update_or_create( $data );
		if ( ! $rs->in_storage ) {
			$rs->insert;
		}
		Logger->info("Saved schedule data for " . $self->descr );
		return true;
	} catch {
		Logger->warn("Failed to save data for " . $self->descr );
		Logger->debug( $_ );
		return false;
	}
}

sub set_start_time {
	my($self, $t) = @_;
	
	if ( defined($t) )
	{
		if ( $t =~ /^\d+$/ ) {
			$self->_start_time($t);
		}
		
		if ( $t =~ /^(\d+):(\d+)$/ ) {
			my $hours = $1;
			my $mins  = $2;
			my $moment = ( 3600 * $hours ) + ( 60 * $mins );
			$self->_start_time($moment);
		}
		
	}
}


sub set_end_time {
	my($self, $t) = @_;
	
	if ( defined($t) )
	{
		if ( $t =~ /^\d+$/ ) {
			$self->_end_time($t);
		}
		
		if ( $t =~ /^(\d+):(\d+)$/ ) {
			my $hours = $1;
			my $mins  = $2;
			my $moment = ( 3600 * $hours ) + ( 60 * $mins );
			$self->_end_time($moment);
		}
		
	}
}

sub is_active
{
	my($self) = @_;
	my($now, $dt, $moment, $active);
	
	#
	# Set default result
	#
	$active = false;
	
	#
	# Get the current timestamp
	#
	$now = time();
	
	#
	# Get the moment
	#
	$dt = DateTime->from_epoch( epoch => $now );
	$moment = ( $dt->hour * 3600 ) + ( $dt->min * 60 );
	
	if ( $moment >= $self->start_time && $moment <= $self->end_time )
	{
		if ( ( $self->start_date > 0 && $self->start_date <= $now ) or $self->start_date == 0 )
		{
			if ( ( $self->end_date > 0 && $self->end_date >= $now ) or $self->end_date == 0  )
			{
				return true;
				
			}
		}
	}
}

1;