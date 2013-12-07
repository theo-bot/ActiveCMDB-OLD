package ActiveCMDB::Controller::Maintenance;

=begin nd

    Script: ActiveCMDB::Controller::Maintenance.pm
    ___________________________________________________________________________

    Version 1.0

    Copyright (C) 2011-2015 Theo Bot

    http://www.activecmdb.org


    Topic: Purpose

    Catalyst Controller for managing maintenance schedules

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
use namespace::autoclean;
use DateTime;
use POSIX;
use DateTime;
use DateTime::Format::Strptime;
use ActiveCMDB::Common::Security;
use ActiveCMDB::Object::Maintenance;
use ActiveCMDB::Common::Constants;

BEGIN { extends 'Catalyst::Controller'; }

my $config = ActiveCMDB::ConfigFactory->instance();
$config->load('cmdb');
my $strp = DateTime::Format::Strptime->new(
	pattern => $config->section('cmdb::default::date_format')
);

my $m_repeat = { 
				0 => 'None',
				1 => 'Daily',
				1 => 'Weekly',
				2 => 'Monthly',
				4 => 'Yearly' 
			}; 

=head2 index

=cut

sub index :Private {
    my ( $self, $c ) = @_;
	
	if ( cmdb_check_role($c,qw/deviceViewer deviceAdmin/) )
	{
		my $format = $config->section('cmdb::default::date_format');
		$format =~ s/\%Y/yy/;
		$format =~ s/\%m/mm/;
		$format =~ s/\d%/dd/;
	
		$format =~ s/\%//g;
	
		$c->stash->{dateFormat} = $format;
		$c->stash->{template} = 'maintenance/container.tt';
	} else {
		$c->response->redirect($c->uri_for($c->controller('Root')->action_for('noauth')));
	} 
}

sub api :Local {
	my($self, $c) = @_;
	
	if ( cmdb_check_role($c,qw/deviceViewer deviceAdmin/) )
	{
	
		if ( defined($c->request->params->{oper}) ) {
			$c->forward($c->request->params->{oper});
		}
	} else {
		$c->response->redirect($c->uri_for($c->controller('Root')->action_for('noauth')));
	}
}

sub list :Local {
	my($self,$c) = @_;
	
	if ( cmdb_check_role($c,qw/deviceViewer deviceAdmin/) )
	{
		my($json,$rs);
		my @rows = ();
	
		$json = undef;
	
		$c->log->debug( $m_repeat);
	
		my $rows	= $c->request->params->{rows} || 10;
		my $page	= $c->request->params->{page} || 1;
		my $order	= $c->request->params->{sidx} || 'domain_id';
		my $asc		= '-' . $c->request->params->{sord};
		my $search = "";
	
		#
		# Get total for the query
		#
		$json->{records} = $c->model('CMDBv1::Maintenance')->search( $search )->count;
		if ( $json->{records} > 0 ) {
			$json->{total} = ceil($json->{records} / $rows );
		} else {
			$json->{total} = 0;
		} 
	
		#
		# Get the data
		#
		$rs = $c->model("CMDBv1::Maintenance")->search( $search );
		while (my $row = $rs->next )
		{
			my $sd = DateTime->from_epoch( epoch => $row->start_date || 0 );
			my $ed = DateTime->from_epoch( epoch => $row->end_date || 0 );
			my $st = moment2time($row->start_time);
			my $et = moment2time($row->end_time);
			push(@rows, { id => $row->maint_id, cell => [
															$row->descr,
															$sd->ymd(),
															$ed->ymd(),
															$st,
															$et,
															$row->m_repeat,
															$m_repeat->{ $row->m_interval }
														] });
		}
		$json->{rows} = [ @rows ];
	
		$c->stash->{json} = $json;
		$c->forward( $c->view('JSON') );
	} else {
		$c->response->redirect($c->uri_for($c->controller('Root')->action_for('noauth')));
	}
}

sub edit :Local {
	my($self, $c) = @_;
	
	if ( cmdb_check_role($c,qw/deviceAdmin/) )
	{
		my($sched, $res);
	
		my $id = $c->request->params->{id};
		$sched = ActiveCMDB::Object::Maintenance->new(maint_id => $id);
		$sched->get_data();
		$sched->set_start_time($c->request->params->{start_time});
		$sched->set_end_time($c->request->params->{end_time});
		if ( defined($c->request->params->{start_date}) && length($c->request->params->{start_date}) > 4 ) {
			my $dt = $strp->parse_datetime($c->request->params->{start_date});
			$sched->start_date( $dt->epoch() );
		}
		if ( defined($c->request->params->{end_date}) && length($c->request->params->{end_date}) > 4 ) {
			my $dt = $strp->parse_datetime($c->request->params->{end_date});
			$sched->end_date( $dt->epoch() );
		}
		$sched->m_repeat( $c->request->params->{m_repeat} || 0 );
		$sched->m_interval( $c->request->params->{m_interval} || 0 );
		$res = $sched->save();
	
		$c->response->body('');
		if ( $res ) {
			$c->response->status(HTTP_OK);
		} else {
			$c->response->status(HTTP_INTERNAL_ERROR);
		}
	} else {
		$c->response->body('');
		$c->response->status->(HTTP_UNAUTHORIZED);
	}
	
}

sub add :Local {
	my($self, $c) = @_;
	
	if ( cmdb_check_role($c,qw/deviceAdmin/) )
	{
		my($sched, $res);
	
		$sched = ActiveCMDB::Object::Maintenance->new();
	
		$sched->set_start_time($c->request->params->{start_time});
		$sched->set_end_time($c->request->params->{end_time});
		if ( defined($c->request->params->{start_date}) && length($c->request->params->{start_date}) > 4 ) {
			my $dt = $strp->parse_datetime($c->request->params->{start_date});
			$sched->start_date( $dt->epoch() );
		}
		if ( defined($c->request->params->{end_date}) && length($c->request->params->{end_date}) > 4 ) {
			my $dt = $strp->parse_datetime($c->request->params->{end_date});
			$sched->end_date( $dt->epoch() );
		}
		$sched->m_repeat( $c->request->params->{m_repeat} || 0 );
		$sched->m_interval( $c->request->params->{m_interval} || 0 );
		$sched->descr( $c->request->params->{descr} );
		$res = $sched->save();
	
		$c->response->body('');
		if ( $res ) {
			$c->response->status(HTTP_OK);
		} else {
			$c->response->status(HTTP_INTERNAL_ERROR);
		}
	} else {
		$c->response->body('');
		$c->response->status(HTTP_UNAUTHORIZED);
	}
}

sub intervals :Local
{
	my($self, $c) = @_;
	
	if ( cmdb_check_role($c,qw/deviceViewer deviceAdmin/) )
	{
		my($json, $data);
	
		$json = undef;
	
		$json = $m_repeat;
	
		$data = "<select>";
		foreach my $i (keys %{$json} )
		{
			$data .= sprintf("<option value='%d'>%s</option>", $i, $json->{$i});
		}
		$data .= "</select>";
	
		$c->response->body($data);
	} else {
		$c->response->body('');
		$c->response->status(HTTP_UNAUTHORIZED);
	}
}

sub moment2time
{
	my($moment) = @_;
	my($hours, $mins,$secs);
	
	$hours  = int($moment / 3600 );
	$secs   = int($moment % 3600 );
	$mins   = int($secs / 60 );
	
	return sprintf("%02d:%02d", $hours, $mins);
}

__PACKAGE__->meta->make_immutable;

1;
