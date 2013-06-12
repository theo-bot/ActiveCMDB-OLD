package ActiveCMDB::Object::Message;

=begin nd

    Script: ActiveCMDB::Object::Message.pm
    ___________________________________________________________________________

    Version 1.0

    Copyright (C) 2011-2015 Theo Bot

    http://www.activecmdb.org


    Topic: Purpose

    Inter Process Message class definition

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

use JSON::XS;
use Data::Dumper;
use Logger;
use Moose;
use Data::UUID;

my $ug = new Data::UUID;

has 'payload'		=> ( is => 'rw', isa => 'Any' );
has 'from'			=> ( is => 'rw', isa => 'Str|Undef' );
has 'reply_to'		=> ( is => 'rw', isa => 'Str|Undef' );
has 'content_type'	=> ( is => 'rw', isa => 'Str|Undef' );
has 'cid'			=> ( is => 'rw', isa => 'Str|Undef' );
has 'subject'		=> ( is => 'rw', isa => 'Str' );
has 'to'			=> ( is => 'rw', isa => 'Str' );
has 'ts1'			=> ( is => 'rw', isa => 'Int|Undef' );
has 'muid'			=> ( 
							is => 'rw', 
							isa => 'Str',
							default => sub { $ug->create_str(); }  
						);			


sub encode_to_json {
	my($self) = @_;
	my $data = undef;
	foreach my $key (__PACKAGE__->meta->get_all_attributes) {
		my $attr = $key->name;
		if ( defined($self->$attr) ) 
		{
			Logger->debug("Adding $attr with value ".$self->$attr." to message");
			$data->{$attr} = $self->$attr;
		}
	}
	my $json = JSON::XS->new->utf8->pretty;

	return $json->encode($data);
}

sub decode_from_json {
	my($self, $msg) = @_;
	
	my $data = JSON::XS->new->utf8->decode($msg);
	
	
	foreach my $key (__PACKAGE__->meta->get_all_attributes ) {
		my $attr = $key->name;
		if ( defined($data->{$attr}) ) {
			$self->$attr($data->{$attr});
		}
	}
}

__PACKAGE__->meta->make_immutable;

1;