package ActiveCMDB::Controller::Import;

use POSIX;
use File::Slurp;
use Moose;
use namespace::autoclean;
use ActiveCMDB::Common::Constants;
use ActiveCMDB::Common::Conversion;
use ActiveCMDB::Common::Import;
use ActiveCMDB::Object::Import;
use Try::Tiny;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

ActiveCMDB::Controller::Import - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

my $config = ActiveCMDB::ConfigFactory->instance();
$config->load('cmdb');

=head2 index

=cut



sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->stash->{template} = 'import/container.tt';
}


=head2 api

Wrapper for jqgrid javascript queries

=cut

sub api :Local
{
	my($self, $c) = @_;
	if ( $c->check_user_roles('admin'))
	{	
		if ( defined($c->request->params->{oper}) ) {
			$c->forward('/import/' . $c->request->params->{oper});
		}
	} else {
		$c->response->redirect($c->uri_for($c->controller('Root')->action_for('noauth')));
	}
}


=head2 list



=cut

sub list :Local {
	my($self, $c) = @_;
	
	my $json = undef;
	my @rows = ();
	my $rows	= $c->request->params->{rows} || 10;
	my $page	= $c->request->params->{page} || 1;
	my $order	= $c->request->params->{sidx} || 'upload_time';
	
	$page--;
	my $start = $page * $rows;
	
	my @imports = cmdb_get_imports($order, $start, $rows );
	
	$json->{records} = scalar @imports;
	if ( $json->{records} > 0 ) {
		$json->{total} = ceil($json->{records} / $rows );
	} else {
		$json->{total} = 0;
	} 
	
	foreach my $import (@imports)
	{
		my $dt = DateTime->from_epoch( epoch => $import->{upload_time});
		push(@rows, { id => $import->{id}, cell => [
														$import->{filename},
														$import->{username},
														$import->{object_type},
														sprintf("%s %s",$dt->ymd, $dt->hms ),
														$import->{tally}
													]
					}
				);
	}
	
	$json->{rows} = [ @rows ];
	$c->stash->{json} = $json;
	$c->forward( $c->view('JSON') );
}

sub edit :Local {
	my($self, $c) = @_;
	
	my $id = $c->request->params->{id};
	
	if ( defined($id) ) 
	{
		$c->log->info("Fetching object $id");
		my $import = ActiveCMDB::Object::Import->new(id => $id);
		$import->get_data();
		$c->stash->{import} = $import;
		$c->stash->{objTypes} = { cmdb_name_set('importObject') };
		
		
		$c->stash->{template} = 'import/edit.tt';
	} else {
		$c->forward('/import/list');
	}
}

sub update :Local {
	my($self, $c) = @_;
	
	my $id = $c->request->params->{id};
	
	if ( defined($id) )
	{
		my $import = ActiveCMDB::Object::Import->new(id => $id);
		$import->get_data();
		foreach my $attr (qw/object_type/)
		{
			if ( defined($c->request->params->{$attr}) )
			{
				$import->$attr($c->request->params->{$attr});
			}
		}
		$import->save();
		$c->response->body('Import object updated');
	} else {
		$c->response->body('Unable to update undefined import object');
	}
}

sub add :Local {
	my($self, $c) = @_;
	
	$c->stash->{objTypes} = { cmdb_name_set('importObject') };
	$c->stash->{template} = 'import/upload.tt';
}

sub upload :Local {
	my($self, $c) = @_;
	my ($fh);
	my $upload = $c->request->upload('filename');
	$c->log->info("filename :" . $upload->tempname);
	my $type = $c->request->params->{object_type} || "";
	
	#
	# Create new import object
	#
	my $import = ActiveCMDB::Object::Import->new();
	$import->username( $c->user->get('username') );
	$import->object_type( $type );
	my $data = '';
	my @data = ();
	open($fh, "<", $upload->tempname );
	while ( <$fh> )
	{
		chomp;
		s/#.*//;
		s/^\s+//;
		s/\s+$//;
		next unless length;
		push(@data, $_);
	}
	close($fh);
	
	# Calculate the number of lines in the file
	$import->tally(scalar @data);
	if ( $import->tally > 0 )
	{
		my $ln = 0;
		foreach (@data) { 
			my $line = ActiveCMDB::Object::Import::Line->new();
			$line->data($_);
			$line->status(0);
			$line->importId($import->id());
			$line->ln($ln++);
			$import->add_line($line);
		}
	} else {
		$c->log->warn("File did not contain data");
	}
	$import->upload_time(time());
	$import->filename($upload->filename);
	
	# Store object
	$import->save();
	
	$c->forward('add');
}

sub discard :Local {
	my($self, $c) = @_;
	
	my $id = $c->request->params->{id};
	
	if ( defined($id) )
	{
		my $import = ActiveCMDB::Object::Import->new(id => $id);
		
		$import->delete();
		$c->response->body('Import object discarded');
	} else {
		$c->response->body("Unable de discard undefined object");
	}

}

=head2 import_start

Start the import of an object

=cut

sub import_start :Local {
	my($self, $c) = @_;
	
	my $id = $c->request->params->{id};
	
	if ( defined($id) )
	{
		try {
			my $p = { 
				job => {
						Type => 'Import',
						id	 => $id
					}
			};
			my $import = ActiveCMDB::Object::Import->new(id => $id);
			$import->get_data();
			$c->response->body('import started');
			my $broker = ActiveCMDB::Common::Broker->new( $config->section('cmdb::broker') );
			$broker->init({ process => 'web'.$$ , subscribe => false });
			my $message = ActiveCMDB::Object::Message->new();
			$message->from('web'.$$ );
			$message->subject('StartJob');
			$message->to($config->section("cmdb::process::worker::exchange"));
			$message->payload($p);
			$c->log->debug("Sending message to " . $message->to );
			$broker->sendframe($message,{ priority => PRIO_HIGH } );
			$c->response->body('import started');
		} catch {
			Logger->error("[1309281633] Failed to send message to broker");
			$c->response->body('failed to start import.');
		}
	}
}

sub import_progress :Local {
	my($self, $c) = @_;
	
	my $id = $c->request->params->{id};
	
	if ( defined($id) )
	{
		my $import = ActiveCMDB::Object::Import->new(id => $id);
		$import->get_data();
		$c->response->body($import->progress);
	}
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
