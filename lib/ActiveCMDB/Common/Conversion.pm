package ActiveCMDB::Common::Conversion;

=begin nd

    Script: ActiveCMDB::Common::Conversion.pm
    ___________________________________________________________________________

    Version 1.0

    Copyright (C) 2012-2013 Theo Bot

    http://www.activecmdb.org


    Topic: Purpose

    Manage conversions

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
use Exporter;
use Logger;
use ActiveCMDB::Model::CMDBv1;
use ActiveCMDB::Schema;
use Try::Tiny;
use strict;

our @ISA = ('Exporter');

our @EXPORT = qw(
	cmdb_convert
	cmdb_add_conversion
	cmdb_del_conversion
	cmdb_list_byname
	cmdb_name_set
);
#########################################################################
# Routines

sub cmdb_convert
{
	my($name, $value) = @_;
	my($schema, $row);
	
	$schema = ActiveCMDB::Model::CMDBv1->instance();
	
	$row = $schema->resultset("Conversion")->find(
		{
			name => $name,
			value => $value	
		},
		{
			columns => [ qw/conversion/ ]
		}
	);
	
	if ( defined($row) ) {
		return $row->conversion;
	}
}

sub cmdb_add_conversion
{
	my($name, $value, $conversion) = @_;
	my($schema, $data);
	
	$schema = ActiveCMDB::Model::CMDBv1->instance();
	
	$data = undef;
	$data->{name} = $name;
	$data->{value} = $value;
	$data->{conversion} = $conversion;
	
	try {
		$schema->resultset("Conversion")->create( $data );
		Logger->info("Created new conversion $name:$value:$conversion");
	} catch {
		Logger->warn("Failed to create new conversion for $name:$value");
	}
}

sub cmdb_del_conversion
{
	my($name, $value) = @_;
	my($schema, $row);
	
	$schema = ActiveCMDB::Model::CMDBv1->instance();
	
	$row = $schema->resultset("Conversion")->find(
		{
			name => $name,
			value => $value	
		}
	);
	
	if ( defined($row) ) {
		return $row->delete;
	}
}

sub cmdb_list_byname
{
	my($name) = @_;
	my($schema, $rs);
	my @list = ();
	
	$schema = ActiveCMDB::Model::CMDBv1->instance();
	$rs = $schema->resultset("Conversion")->search(
		{
			name => $name
		},
		{
			columns => [ qw/value conversion/ ]
		}
	);
	
	if ( defined($rs) )
	{
		while ( my $row = $rs->next )
		{
			push(@list, { key => $row->value, value => $row->conversion });
		}
	}
	
	return @list;
}

sub cmdb_name_set
{
	my($name) = @_;
	my($schema,$rs);
	my %set = ();
	
	$schema = ActiveCMDB::Model::CMDBv1->instance();
	$rs = $schema->resultset("Conversion")->search(
		{
			name => $name
		},
		{
			columns => [ qw/value conversion/ ]
		}
	);
	
	if ( defined($rs) )
	{
		while ( my $row = $rs->next )
		{
			$set{ $row->value } = $row->conversion;
		}
	}
	
	return %set;
}