package ActiveCMDB::Common::Conversion;

=head1 MODULE - ActiveCMDB::Common::Conversion
    ___________________________________________________________________________

=head1 VERSION

    Version 1.0

=head1 COPYRIGHT

    Copyright (C) 2011-2015 Theo Bot

    http://www.activecmdb.org


=head1 DESCRIPTION

    Manage conversions

=head1 LICENSE

    This program is free software; you can redistribute it and/or
    modify it under the terms of the GNU General Public License
    as published by the Free Software Foundation; either version 2
    of the License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

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

=head1 FUNCTIONS

=head2 cmdb_convert

Convert a name/value pair

=head3 Arguments
 $name		- Conversation set name
 $value		- Conversation item in the named set

=head3 Return
 SCALAR		- Converted name/value pair
 undef		- If now conversation was found
 
=cut

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

=head2 cmdb_add_conversion

Add a conversion to the database.

=head3 Arguments
 $name			- Conversion set name
 $value			- Conversation item in set
 $conversion	- Converted value
=cut

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