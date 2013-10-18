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
use Data::Dumper;

our @ISA = ('Exporter');

our @EXPORT = qw(
	cmdb_convert
	cmdb_add_conversion
	cmdb_del_conversion
	cmdb_list_byname
	cmdb_name_set
	cmdb_oid_set
	cmdb_export_conv
);
#########################################################################
# Routines

=head1 FUNCTIONS

=head2 cmdb_convert

Convert a name/value pair

 Arguments
 $name		- Conversation set name
 $value		- Conversation item in the named set

 Returns
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

 Arguments
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

=head2 cmdb_del_conversion

Delete a conversion from a conversion set.

 Arguments
 $name	- Name of the conversion set
 $value	- Conversion item in set

=cut

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

=head2 cmdb_list_byname
Get a list of value/conversion pairs for a specific conversion set

 Arguments
 $name	- String containing the name of the conversion set
 
 Returns
 @list	- Array containing the list of pairs
=cut

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

=head2 cmdn_name_set
Get an assciative list of value/conversion for a specific set

 Arguments:
 $name	- String containing a set name
 
 Returns:
 %set	- Hash containing the value/conversions
=cut

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

sub cmdb_oid_set
{
	my($name) = @_;
	my($schema,$rs);
	my %set = ();
	
	$schema = ActiveCMDB::Model::CMDBv1->instance();
	$rs = $schema->resultset('Snmpmib')->search(
		{
			oidname	=> $name,
			value	=> { '!=' => undef}
		},
		{
			columns => [ qw/value mibvalue/ ]
		}
	);
	
	if ( defined($rs) )
	{
		Logger->debug("Processing values for $name");
		while ( my $row = $rs->next )
		{
			Logger->debug("Adding value for " . $row->value);
			my $x = $row->value;
			$set{ $x } = $row->mibvalue ;
		}
	} else {
		Logger->warn("Unknown resultset");
	}
		
	return %set
}

=head2 exportConv

Generate a list of conversion commands to save the conversion table

=cut

sub cmdb_export_conv
{
	my($schema, $rs);
	
	$schema = ActiveCMDB::Model::CMDBv1->instance();
	$rs = $schema->resultset("Conversion")->search(
			undef,
			{
				order_by	=> qw/name value/
			}
	);
	
	if ( defined($rs) )
	{
		while(my $row = $rs->next)
		{
			printf('$CMDB_HOME/bin/cmdb_convert.pl -add -name %s -from "%s" -to "%s"', 
				$row->name,
				$row->value,
				$row->conversion
			);
			print "\n";
		}
	}
}