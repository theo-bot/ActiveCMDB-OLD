package ActiveCMDB::Controller::Disco;
use Moose;
use namespace::autoclean;
use POSIX;
use MIME::Base64;
use Image::Info qw(image_info dim);
use Data::Dumper;
use ActiveCMDB::Common::Security;
use ActiveCMDB::Common::Constants;
use ActiveCMDB::Common::Conversion;
use ActiveCMDB::Object::Disco;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

ActiveCMDB::Controller::Disco - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Private {
    my ( $self, $c ) = @_;
	
	if ( cmdb_check_role($c,qw/deviceViewer deviceAdmin/) )
	{
		$c->stash->{template} = 'disco/container.tt';
	} else {
		$c->response->redirect($c->uri_for($c->controller('Root')->action_for('noauth')));
	}
}

sub api :Local {
	my($self, $c) = @_;
	
	if ( defined($c->request->params->{oper}) ) {
		$c->forward($c->request->params->{oper});
	}
}

sub list :Local {
	my($self, $c) = @_;
	
	if ( cmdb_check_role($c,qw/deviceViewer deviceAdmin/) )
	{
		my($json,$rs);
		my @rows = ();
		my %schemes = ();
	
		$json = undef;
	
		my $rows	= $c->request->params->{rows} || 10;
		my $page	= $c->request->params->{page} || 1;
		my $order	= $c->request->params->{sidx} || 'scheme_id';
		my $asc		= '-' . $c->request->params->{sord};
		my $search = undef;
	
		#
		# Get total for the query
		#
		#$c->log->debug("$search");
		$json->{records} = $c->model('CMDBv1::DiscoScheme')->search( {} )->count;
		if ( $json->{records} > 0 ) {
			$json->{total} = ceil($json->{records} / $rows );
		} else {
			$json->{total} = 0;
		} 
	
		#
		# Get the data
		#
	
		$rs = $c->model('CMDBv1::DiscoScheme')->search(
					$search,
					{
						order_by => { $asc => $order },
						rows	 => $rows,
						page	 => $page,
						columns  => qw/scheme_id/
					}
				);
			
		while ( my $row = $rs->next )
		{
			my $disco = ActiveCMDB::Object::Disco->new(scheme_id => $row->scheme_id);
			$disco->get_data();
			push(@rows, { id => $disco->scheme_id, cell=> [	
															$disco->name,
															$disco->active,
															$disco->block2str('block1'),
															$disco->block2str('block2')								
														] 
						}
				);
		}
		$json->{rows} = [ @rows ];
		#$c->log->debug(Dumper($json));
		$c->stash->{json} = $json;
	
		$c->forward( $c->view('JSON') );
	} else {
		$c->response->redirect($c->uri_for($c->controller('Root')->action_for('noauth')));
	}
}


sub view :Local {
	my($self, $c) = @_;
	my($disco);
	
	if ( cmdb_check_role($c,qw/deviceViewer deviceAdmin/) )
	{
		if ( defined($c->request->params->{scheme_id}) && int($c->request->params->{scheme_id}) > 0 )
		{
			$disco = ActiveCMDB::Object::Disco->new(scheme_id => int($c->request->params->{scheme_id}) );
			$disco->get_data();
		} else {
			$disco = ActiveCMDB::Object::Disco->new();
		}
	
		$c->stash->{admin} = cmdb_check_role($c, qw/deviceAdmin/);
		$c->stash->{disco} = $disco; 
		$c->stash->{template} = 'disco/view.tt';
	} else {
		$c->response->redirect($c->uri_for($c->controller('Root')->action_for('noauth')));
	}
}

sub save :Local {
	my($self, $c) = @_;
	
	if ( cmdb_check_role($c,qw/deviceAdmin/) )
	{
		my($disco);
	
		if ( defined($c->request->params->{scheme_id}) && int($c->request->params->{scheme_id}) > 0 )
		{
			$disco = ActiveCMDB::Object::Disco->new(scheme_id => int($c->request->params->{scheme_id}) );
			$disco->get_data();
		} else {
			$disco = ActiveCMDB::Object::Disco->new();
		}
	
		if ( ! $c->request->params->{active} ) { $c->request->params->{active} = 0; }
		foreach my $attr (qw/active block1 block2 name/)
		{
			if ( defined($c->request->params->{$attr}) && $disco->can($attr) ) {
				$disco->$attr($c->request->params->{$attr});
			}
		}
		if ( $disco->save() )
		{
			$c->response->status(HTTP_OK);
		} else {
			$c->response->status(HTTP_INTERNAL_ERROR);
		}
	} else {
		$c->response->status(HTTP_UNAUTHORIZED);
	}
	$c->response->body('');
}

sub del :Local {
	my($self, $c) = @_;
	
	if ( cmdb_check_role($c,qw/deviceAdmin/) )
	{
		if ( defined($c->request->params->{scheme_id}) && int($c->request->params->{scheme_id}) > 0 )
		{
			my $disco = ActiveCMDB::Object::Disco->new(scheme_id => int($c->request->params->{scheme_id}) );
			$disco->get_data();
			if ( $disco->name ne 'default' )
			{
				if ( $disco->delete() ) {
					$c->response->status(HTTP_OK);
				} else {
					$c->response->status(HTTP_INTERNAL_ERROR);
				}
			} else {
				$c->response->status(HTTP_UNAUTHORIZED);
			}
		} else {
			$c->response->status(HTTP_INTERNAL_ERROR);
		}
	} else {
		$c->response->status(HTTP_UNAUTHORIZED);
	}
	$c->response->body('');
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
