package ActiveCMDB::Controller::Endpoint;

=begin nd

    Script: ActiveCMDB::Controller::Endpoint.pm
    ___________________________________________________________________________

    Version 1.0

    Copyright (C) 2012-2013 Theo Bot

    http://www.activecmdb.org


    Topic: Purpose

    Catalyst Controller for Distribution Endpoints

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

	Topic: Description
	
	This module performs actions on the conversions table
	
	
=cut

use Moose;
use POSIX;
use Try::Tiny;
use namespace::autoclean;
use ActiveCMDB::Common;
use ActiveCMDB::Common::Conversion;
use ActiveCMDB::Object::Endpoint;
use Data::Dumper;

BEGIN { extends 'Catalyst::Controller'; }


sub index :Private {
    my ( $self, $c ) = @_;

	$c->stash->{template} = 'distrib/ep_container.tt';
   
}

sub api: Local {
	my($self, $c) = @_;
	
	if ( defined($c->request->params->{oper}) ) {
		$c->forward('/endpoint/' . $c->request->params->{oper});
	}
}

sub list: Local {
	my($self, $c) = @_;
	my($rs,$json);
	my @rows = ();
	my $rows	= $c->request->params->{rows} || 10;
	my $page	= $c->request->params->{page} || 1;
	my $order	= $c->request->params->{sidx} || 'name';
	my $asc		= '-' . $c->request->params->{sord};
	
	$rs = $c->model("CMDBv1::DistEndpoint")->search(
				undef,
				{
					rows		=> $rows,
					page		=> $page,
					order_by	=> { $asc => $order },
				}
	);
	
	$json->{records} = $rs->count;
	if ( $json->{records} > 0 ) {
		$json->{total} = ceil($json->{records} / $c->request->params->{rows} );
	} else {
		$json->{total} = 0;
	} 
	
	while ( my $row = $rs->next )
	{
		push(@rows, { id => $row->ep_id, cell=> [
														$row->ep_name,
														$row->ep_method,
														$row->ep_active,
														$row->ep_dest_in,
														$row->ep_dest_out													]
					}
			);
	}
	
	$json->{rows} = [ @rows ];
	$c->stash->{json} = $json;
	$c->forward( $c->view('JSON') );
}

sub add :Local {
	my($self,$c) = @_;
	my @methods = qw/JMS AMQP FTP SCP/;
	
	$c->stash->{mime_types} = [ cmdb_list_byname('mime_type') ];
	$c->stash->{methods}  	= [ @methods ];
	$c->stash->{template}	= 'distrib/ep_edit.tt';
}

sub edit :Local {
	my($self,$c) = @_;
	my @methods = qw/JMS AMQP FTP SCP/;
	
	if ( defined($c->request->params->{id}) && $c->request->params->{id} > 0 )
	{
		my $id = $c->request->params->{id};
		$c->log->debug("Fetching data for $id");
		my $ep = ActiveCMDB::Object::Endpoint->new(id => $id );
		#$c->log->debug(Dumper($ep));
		$ep->get_data();
		
		$c->stash->{ep} = $ep;
		$c->stash->{mime_types} = [ cmdb_list_byname('mime_type') ];
		$c->stash->{methods}  	= [ @methods ];
		$c->log->info("Rendering template ep_edit.tt");
		$c->stash->{template}	= 'distrib/ep_edit.tt';
	} else {
		$c->forward('/endpoint/add');
	}
}

sub save :Local {
	my($self, $c) = @_;
	
	
	my $ep = ActiveCMDB::Object::Endpoint->new();
	my %map = $ep->map;
	foreach my $method (keys(%map)) {
		if ( defined( $c->request->params->{$method}) ) {
			#$c->log->info("Found key $method");
			
			if ( $method eq 'id' && $c->request->params->{$method} eq "" ) { $c->request->params->{$method} = undef; }
			if ( $method =~ /^(active|create|update|delete|encrypt)$/ ) { 
				$c->request->params->{$method} = 1;
			}
			
			$ep->$method($c->request->params->{$method});
			
		} else {
			if ( $method =~ /^active|create|update|delete|encrypt$/ ) {
				$ep->$method(0);
			}
		}
	}
	$ep->save;
	
	my %yesno = ('yes' => 1, 'no' => 0);
	
	if ( reftype($c->request->params->{subject}) ne 'ARRAY' ) 
	{
		$c->log->info("msg_active=". $c->request->params->{msgactive});
		my $epm = ActiveCMDB::Object::Endpoint::Message->new( 
						subject => $c->request->params->{subject},
						id      => $ep->id,
						mimetype	=> $c->request->params->{mimetype},
						message		=> $c->request->params->{ep_message}	,
						active		=> $yesno{$c->request->params->{msgactive}}		
				);
		$epm->save();
		
	} else {
		
		my @subjects	= @{$c->request->params->{subject}};
		my @mimetypes	= @{$c->request->params->{mimetype}};
		my @messages	= @{$c->request->params->{ep_message}};
		my @active		= @{$c->request->params->{msg_active}};
		
		my $tally = scalar(@subjects);
		$c->log->debug(Dumper(@subjects));
		for (my $i=0; $i<$tally; $i++) 
		{
			$c->log->info("\$i => $i :: $tally");
			my $epm = ActiveCMDB::Object::Endpoint::Message->new( 
						subject => $subjects[$i],
						id      => $ep->id,
						mimetype	=> $mimetypes[$i],
						message		=> $messages[$i],
						active		=> $yesno{$active[$i]}
				);
			$epm->save();
		}
	}
	
	
	$c->response->body('Done');
	$c->response->status(200);
}

sub find_by_subject :Local {
	my($self, $c) = @_;
	
	my @json = ();
	my $searchStr = $c->request->params->{name_startsWith}.'%';
	my $maxRows   = $c->request->params->{maxRows};
	
	try {
		my $rs = $c->model("CMDBv1::DistMessage")->search(
			subject => { like =>  $searchStr }
		);
		
		while ( my $row = $rs->next )
		{
			push(@json, { id => $row->subject, label => $row->subject });
		}
	} catch {
		$c->log->warn("Failed to get subjects." . $_);
	};
	
	$c->stash->{json} = { names => \@json };
	$c->forward( $c->view('JSON') );
}

sub get_mimetype :Local {
	my($self, $c) = @_;
	
	my $row = $c->model('CMDBv1::DistMessage')->find(
		{
			subject => $c->request->params->{subject}
		},
		{
			columns => qw/mimetype/
		}
	);
	if ( defined($row) ) {
		$c->response->body( $row->mimetype );
		#$c->response->body( "ABC");
	} else {
		$c->response->body("");
	}
}

=head1 AUTHOR

Theo Bot

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
