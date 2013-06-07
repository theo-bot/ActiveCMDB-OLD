package ActiveCMDB::Object::Endpoint::Message;
{
=begin nd

    Script: ActiveCMDB::Object::Endpoint.pm
    ___________________________________________________________________________

    Version 1.0

    Copyright (C) 2012-2013 Theo Bot

    http://www.activecmdb.org


    Topic: Purpose

    ActiveCMDB::Object::Endpoint::Message class definition

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
use MooseX::Privacy;
use Try::Tiny;
use Logger;
use Data::Dumper;

has 'id'			=> (is => 'ro', isa => 'Int|Undef');
has 'subject'		=> (is => 'ro', isa => 'Str' );
has 'active'		=> (is => 'rw', isa => 'Int', default => 0 );
has 'mimetype'		=> (is => 'rw', isa => 'Str');
has 'message'		=> (is => 'rw', isa => 'Str|Undef');

has 'schema'			=> (
	is 		=> 'rw', 
	isa 	=> 'Object', 
	default => sub { ActiveCMDB::Model::CMDBv1->instance() },
	traits	=> [qw/Private/],
);

with 'ActiveCMDB::Object::Methods';

my %map = (
	id			=> 'ep_id',
	subject		=> 'subject',
	active		=> 'active',
	message		=> 'message',
	mimetype	=> 'mimetype'
);

sub get_data {
	my($self) = @_;
	
	if ( defined($self->id) && defined($self->subject) )
	{
		Logger->debug("Fetching endpoint message");
		try {
			my $row = $self->schema->resultset('DistEpMessage')->find(
				{
					ep_id 	=> $self->id,
					subject	=> $self->subject
				}
			);
		
		
			if ( defined($row) ) {
				$self->active($row->active);
				$self->mimetype($row->mimetype);
				$self->message($row->message);
			} else {
				Logger->warn("Unable to fetch row");
			}
		} catch {
			Logger->warn("Failed to fect endpoint message.\n" . $_);
		};
	}
}

sub save {
	my($self) = @_;
	
	if ( defined($self->id) && defined($self->subject) )
	{
		Logger->info("Saving endpoint message.");
		try {
			my $data = $self->to_hashref(\%map);
			$self->schema->resultset("DistEpMessage")->update_or_create( $data );
		} catch {
			Logger->warn("Failed to save endpoint message.\n". $_);
		};
	}
}

sub parse {
	my($self, $os) = @_;
	
	my $msg = $self->message;
	
	while ( $msg =~ /(\[.+?\])/ )
	{
		my $x = $1;
	 	if ( $x =~ /\[(.+?)\.(.+)\]/ )
	 	{
	 		my $object = $1;
	 		my $method = $2;
	 		my $newval = $os->{$object}->$method();
	 		$x =~ s/\[/\\\[/;
	 		$x =~ s/\]/\\\]/;
	 		$msg =~ s/$x/$newval/s;
	 	}
	}	
	return $msg;
}

1;

}