package ActiveCMDB::Controller::Contract;

=head1 MODULE - ActiveCMDB::Controller::Contract
    ___________________________________________________________________________

=head1 VERSION

    Version 1.0

=head1 COPYRIGHT

    Copyright (C) 2011-2015 Theo Bot

    http://www.activecmdb.org


=head1 DESCRIPTION

    Catalyst Controller for managing contracts

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

use Moose;
use namespace::autoclean;
use DateTime;
use POSIX;
use DateTime;
use DateTime::Format::Strptime;
use Data::Dumper;
use ActiveCMDB::Object::Contract;
use ActiveCMDB::Common::Vendor;

BEGIN { extends 'Catalyst::Controller'; }

my $config = ActiveCMDB::ConfigFactory->instance();
$config->load('cmdb');
my $strp = DateTime::Format::Strptime->new(
	pattern => $config->section('cmdb::default::date_format')
);

sub index :Private {
    my ( $self, $c ) = @_;
	
	my $format = $config->section('cmdb::default::date_format');
	$format =~ s/\%Y/yy/;
	$format =~ s/\%m/mm/;
	$format =~ s/\d%/dd/;
	
	$format =~ s/\%//g;
	
	$c->stash->{dateFormat} = $format;
	$c->stash->{template} = 'contract/container.tt';
   
}

sub api :Local {
	my($self, $c) = @_;
	
	if ( defined($c->request->params->{oper}) ) {
		$c->forward('/contract/' . $c->request->params->{oper});
	}
}

sub list :Local {
	my($self, $c) = @_;
	my($rs, $json);
	my @rows = ();
	
	my $rows	= $c->request->params->{rows} || 10;
	my $page	= $c->request->params->{page} || 1;
	my $order	= $c->request->params->{sidx} || 'contract_number';
	my $asc		= '-' . $c->request->params->{sord};
	
	$rs = $c->model("CMDBv1::Contract")->search(
				{
				},
				{
					rows		=> $rows,
					page		=> $page,
					join		=> 'vendor',
					'+select'	=> ['vendor.vendor_name'],
					'+as'		=> ['vendor_name'],
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
		my $start = substr($row->start_date,0,10);
		my $end   = substr($row->end_date,0,10);
		push(@rows, { id => $row->contract_id, cell=> [
														$row->contract_number,
														$row->contract_descr,
														$row->get_column('vendor_name'),
														$start,
														$end
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
	
	if ( defined($c->request->params->{id}) )
	{
		$c->log->debug("Fetching data for contract id " . $c->request->params->{id} );
		my $contract = ActiveCMDB::Object::Contract->new(id => $c->request->params->{id} );
		$contract->get_data();
		$c->stash->{contract} = $contract;
		$c->log->info("Found data for contract number " . $contract->number);
		$c->log->debug("Contract vendor_id " . $contract->vendor_id);
	} else {
		$c->log->warn("Contract id was not defined or zero");
	}
	my %vendors = cmdb_get_vendors();
	$c->stash->{vendors} = \%vendors;
	$c->stash->{template} = 'contract/edit.tt';
}



__PACKAGE__->meta->make_immutable;

1;
