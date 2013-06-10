package ActiveCMDB::Object::Methods;

=begin nd

    Script: ActiveCMDB::Object::Methods.pm
    ___________________________________________________________________________

    Version 1.0

    Copyright (C) 2012-2013 Theo Bot

    http://www.activecmdb.org


    Topic: Purpose

    Generic Mixin library

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

use Data::Dumper;
use Logger;
use Moose::Role;

sub to_hashref
{
	my($self, $map) = @_;
	my($key,$attr,$data);
	
	$data = undef;
	
	
	if ( defined( $map ) )
	{
		my %map = %{$map};
		foreach $attr (keys %map)
		{
			$data->{ $map{$attr} } = $self->$attr;
		}	
	} else {
		foreach $key ( $self->meta->get_all_attributes )
		{
			$attr = $key->name;
			next if ( $attr =~ /schema/ );
			$data->{$attr} = $self->$attr();
		}
	}
	
	return $data;
}

sub populate
{
	my($self,$data, $map) = @_;
	
	if ( defined($map) )
	{
		my %map = %{$map};
		foreach my $attr (keys %map)
		{
			my $m = $map{$attr};
			$self->$attr($data->$m());
		}
	}
}

1;