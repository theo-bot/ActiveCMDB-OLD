package ActiveCMDB::Controller::Journal;
use Moose;
use namespace::autoclean;
use POSIX;
use DateTime;
use Data::Dumper;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

ActiveCMDB::Controller::Journal - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub api :Local {
	my($self, $c) = @_;
	
	if ( defined($c->request->params->{oper}) ) {
		$c->forward('/journal/' . $c->request->params->{oper});
	}
}

sub list :Local {
	my($self, $c) = @_;
	my($rs, $json);
	my @rows = ();
	
	my $rows	= $c->request->params->{rows} || 10;
	my $page	= $c->request->params->{page} || 1;
	my $order	= $c->request->params->{sidx} || 'journal_date';
	my $asc		= '-' . $c->request->params->{sord};
	
	$rs = $c->model("CMDBv1::IpDeviceJournal")->search(
				{
					device_id	=> $c->request->params->{device_id},
				},
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
		my $date = sprintf("%s", $row->journal_date);
		$date =~ s/T/ /;
		push(@rows, { id => $row->journal_id, cell=> [
														$date,
														$row->user,
														$row->journal_data
													]
					}
			);
	}
	
	$json->{rows} = [ @rows ];
	$c->stash->{json} = $json;
	$c->forward( $c->view('JSON') );
}

sub add :Local {
	my($self, $c) = @_;
	
	my $data = undef;
	if ( defined($c->request->params->{journal_data}) && length($c->request->params->{journal_data}) > 2 )
	{
		my $journal = ActiveCMDB::Object::Journal->new(device_id => $c->request->params->{device_id});
		$journal->data($c->request->params->{journal_data});
		$journal->prio(5);
		$journal->user($c->user->get('username'));
		$journal->date(DateTime->now());
		$journal->save();
	}
	
	
	$c->response->status(200);
	$c->response->body('');
}

sub edit :Local {
	my($self, $c) = @_;
	
	my $data = undef;
	if ( defined($c->request->params->{journal_data}) && length($c->request->params->{journal_data}) > 2  )
	{
		my $journal = ActiveCMDB::Object::Journal->new(
							device_id 	=> $c->request->params->{device_id},
							journal_id	=> $c->request->params->{id}
						);
		$journal->get_data();
		$journal->data($c->request->params->{journal_data});
		$journal->save();
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
