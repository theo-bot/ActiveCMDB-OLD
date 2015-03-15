package ActiveCMDB::Controller::Compliance;
use Moose;
use namespace::autoclean;
use POSIX;
use Switch;
use Data::Dumper;
use DateTime;
#use ActiveCMDB::Common::Compliance;
use ActiveCMDB::ConfigFactory;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

ActiveCMDB::Controller::Compliance - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

my $config = ActiveCMDB::ConfigFactory->instance();
$config->load('cmdb');

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->response->body('Matched ActiveCMDB::Controller::Compliance in Compliance.');
}

sub rules :Local {
	my($self, $c) = @_;
	
	my ($rs, $json, $search);
	
	my @rows = ();
	
	my $rows	= $c->request->params->{rows} || 10;
	my $page	= $c->request->params->{page} || 1;
	my $order	= $c->request->params->{sidx} || 'name';
	my $asc = '-asc';
	if ( defined($c->request->params->{sord}) ) {
		$asc	= '-' . $c->request->params->{sord};
	}
	
		#
		# Create search filter
		#
		if ( $c->request->params->{_search} eq 'true' )
		{
			my $searchOper   = $c->request->params->{searchOper};
			my $searchField  = $c->request->params->{searchField};
			my $searchString = $c->request->params->{searchString};
		
			switch ( $searchOper ) {
				case 'cn'		{ $search = { $searchField => { like => '%'.$searchString.'%' } } }
				case 'eq'		{ $search = { $searchField => $searchString } }
				case 'ne'		{ $search = { $searchField => { '!=' => $searchString } } }
				case 'bw'		{ $search = { $searchField => { like => $searchString.'%' } } }
				else 			{ $search = { } }
			}
		} else {
			$search = { };
		}
		$c->log->debug("Search:\n" . Dumper($search));
	
		$c->log->info("Order $asc => $order");
		$rs = $c->model("CMDBv1::ConfigRule")->search(
					$search,
					{
						rows		=> $rows,
						page		=> $page,
						order_by	=> { $asc => $order },
					}
		);
	
		$json->{records} = $rs->count;
		if ( $json->{records} > 0 ) {
			$json->{total} = ceil($json->{records} / $rows );
		} else {
			$json->{total} = 0;
		} 
	
		while ( my $row = $rs->next )
		{
			my $last_update = DateTime->from_epoch(epoch => $row->last_update);
			push(@rows, { id => $row->rule_id, cell=> [
															$row->name,
															$last_update->strftime($config->section('cmdb::default::date_format')),
															$row->updated_by															
														]
						}
				);
		}
	
		$json->{rows} = [ @rows ];
		$c->stash->{json} = $json;
		$c->forward( $c->view('JSON') );
	
}

=encoding utf8

=head1 AUTHOR

Theo Bot

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
