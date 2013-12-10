package ActiveCMDB::Controller::Ipdomain;

=begin nd

    Script: ActiveCMDB::Controller::Ipdomain.pm
    ___________________________________________________________________________

    Version 1.0

    Copyright (C) 2011-2015 Theo Bot

    http://www.activecmdb.org


    Topic: Purpose

    Manage ip domains within ActiveCMDB

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
use namespace::autoclean;
use POSIX;
use Data::Dumper;
use NetAddr::IP;
use DateTime;
use DateTime::Format::Strptime;
use ActiveCMDB::Common::Security;
use ActiveCMDB::Object::Ipdomain;
use ActiveCMDB::Common::Constants;

BEGIN { extends 'Catalyst::Controller'; }

my $config = ActiveCMDB::ConfigFactory->instance();
$config->load('cmdb');
my $strp = DateTime::Format::Strptime->new(
	pattern => $config->section('cmdb::default::date_format')
);

sub list_domains :Local {
    my ( $self, $c ) = @_;
    
    if ( cmdb_check_role($c, qw/networkViewer networkAdmin/) )
    {
		my($rs, $json, $search);
		my @rows = ();
	
		my @domains = ();
		my $rows	= $c->request->params->{rows} || 10;
	
    	$rs =	$c->model('CMDBv1::IpDomain')->search(
    								{},
    								{
    									join	 => 'ip_domain_networks',
    									select	 => [ 'domain_id', 'domain_name', { count => 'ip_domain_networks.domain_id' } ],
    									as		 => [ qw/domain_id domain_name tally/ ],
    									group_by => [ qw/ domain_id/ ]
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
			push(@rows, { id => $row->domain_id, cell=> [
															$row->domain_name,
															$row->get_column('tally')										
														]
						}
				);
		}
	
		$json->{rows} = [ @rows ];
		$c->stash->{json} = $json;
		$c->log->debug(Dumper($json));
		$c->forward( $c->view('JSON') );
    } else {
    	$c->response->redirect($c->uri_for($c->controller('Root')->action_for('noauth')));
    }    
}

sub index :Private {
	my($self, $c) = @_;
	
	if ( cmdb_check_role($c, qw/networkViewer networkAdmin/) )
	{
		my $format = $config->section('cmdb::default::date_format');
		$format =~ s/\%Y/yy/;
		$format =~ s/\%m/mm/;
		$format =~ s/\d%/dd/;
	
		$format =~ s/\%//g;
	
		$c->stash->{dateFormat} = $format;
	
		$c->stash->{template} = 'domain/list.tt';
	} else {
		$c->response->redirect($c->uri_for($c->controller('Root')->action_for('noauth')));
	}
}

sub api :Local {
	my($self, $c) = @_;
	
	if ( defined($c->request->params->{oper}) ) {
		$c->forward('/ipdomain/' . $c->request->params->{oper});
	}
}

sub view :Local {
	my( $self, $c ) = @_;
	
	if ( cmdb_check_role($c, qw/networkViewer networkAdmin/) )
	{
		my($domain_id, $rs, $row);
		my @networks = ();
	
		$domain_id = $c->request->params->{domain_id};
		$c->log->debug(Dumper($c->request->params));
	
	
		if ( defined($domain_id) )
		{
			my $domain = $c->model('CMDBv1::IpDomain')->find({ domain_id => $domain_id });
		
			if ( defined($domain) )
			{
				$c->log->info("Domain record found");
				$c->stash->{domain} = $domain;
			} else {
				$c->log->warn("Domain record not found.");
			}
			$rs = $c->model('CMDBv1::IpDomainNetwork')->search(
						{
							domain_id => $domain_id
						},
						{
							order_by => [ qw/ip_network/ ]
						}
				);
			
			while ( $row = $rs->next )
			{
				push(@networks, $row);
			}
			$c->stash->{networks} = [ @networks ];
		
		} else {
			$c->log->warn("Domain id undefined.");
		}
	
		$c->stash->{template} = 'domain/view.tt';
	} else {
		$c->response->redirect($c->uri_for($c->controller('Root')->action_for('noauth')));
	}
}


sub network :Local {
	my($self, $c ) = @_;
	
	if ( defined($c->request->params->{oper}) ) {
		$c->forward($c->request->params->{oper});
	}
}

sub list :Local {
	my($self, $c) = @_;
	if ( cmdb_check_role($c, qw/networkViewer networkAdmin/) )
	{
		my ($rs,$search);
		my @data = ();
		my @rows = ();
	
		my $json = undef;
	
		my $id 		= $c->request->params->{domain_id} || 0;
		my $rows	= $c->request->params->{rows} || 10;
		my $page	= $c->request->params->{page} || 1;
		my $order	= $c->request->params->{sidx} || 'domain_id';
		my $asc		= '-' . $c->request->params->{sord};
	
	
		#
		# Create search filter
		#
		if ( $c->request->params->{_search} eq 'true' )
		{
			my $searchOper   = $c->request->params->{searchOper};
			my $searchField  = $c->request->params->{searchField};
			my $searchString = $c->request->params->{searchString};
			if ( $searchOper eq 'cn' ) {
				$search = { $searchField => { like => '%'.$searchString.'%' } };
			}
			if ( $searchOper eq 'eq' ) {
				$search = { $searchField => $searchString };
			}
			if ( $searchOper eq 'ne' ) {
				$search = { $searchField => { '!=' => $searchString } };
			}
		
		} else {
			$search = { domain_id => $id };
		}
	
		#
		# Get total for the query
		#
		$json->{records} = $c->model('CMDBv1::IpDomainNetwork')->search( $search )->count;
		if ( $json->{records} > 0 ) {
			$json->{total} = ceil($json->{records} / $rows );
		} else {
			$json->{total} = 0;
		} 
	
		#
		# Get the data
		#
		$rs = $c->model('CMDBv1::IpDomainNetwork')->search(
					$search,
					{
						order_by => { $asc => $order },
						rows	 => $rows,
						page	 => $page
					}
				);
			
		while ( my $row = $rs->next )
		{
			push(@rows, { id => $row->network_id, cell=> [	
															$row->ip_network,
															$row->ip_mask,
															$row->ip_masklen,
															$row->active,
															$row->snmp_ro || "",
															$row->snmp_rw || "",
															$row->telnet_user || "",
															$row->telnet_pwd || "",
															$row->snmpv3_user || "",
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

sub edit :Local {
	my($self, $c) = @_;
	
	if ( cmdb_check_role($c, qw/networkAdmin/) )
	{
		my($data,$rs,$net);
	
		$data = undef;
		foreach my $f (qw/domain_id ip_network ip_mask ip_masklen active snmp_ro snmp_rw telnet_user telnet_pwd snmpv3_user snmpv3_pass1 snmpv3_pass2 snmpv3_proto1 snmpv3_proto2/)
		{
			$data->{$f} = $c->request->params->{$f};
		}
		$data->{network_id} = $c->request->params->{id};
		$net = NetAddr::IP->new($data->{ip_network});
		if ( !defined($data->{ip_mask}) && defined($data->{ip_masklen}) )
		{
			$net = NetAddr::IP->new($data->{ip_network} . '/' . $data->{ip_masklen});
			$data->{ip_mask} = $net->mask();
		} elsif ( defined($data->{ip_mask}) && !defined($data->{ip_masklen}) ) {
			$net = NetAddr::IP->new($data->{ip_network}, $data->{ip_mask});
			$data->{ip_masklen} = $net->masklen();	
		}
	
		if ( $data->{active} eq 'Yes' ) { $data->{active} = 1; } else { $data->{active} = 0; }
		$c->model('CMDBv1::IpDomainNetwork')->update_or_create( $data );
		$c->response->status(HTTP_OK);
		$c->response->body('');
	} else {
		$c->response->status(HTTP_UNAUTHORIZED);
		$c->response->body('');
	}
}

sub add :Local {
	my($self, $c) = @_;
	
	if ( cmdb_check_role($c, qw/networkAdmin/) )
	{
		my($data,$rs,$net);
	
		$data = undef;
		foreach my $f (qw/domain_id ip_network ip_mask ip_masklen active snmp_ro snmp_rw telnet_user telnet_pwd snmpv3_user snmpv3_pass1 snmpv3_pass2 snmpv3_proto1 snmpv3_proto2/)
		{
			$data->{$f} = $c->request->params->{$f};
		}
		$data->{network_id} = undef;
		$net = NetAddr::IP->new($data->{ip_network});
		if ( !$data->{ip_mask} && $data->{ip_masklen} )
		{
			$c->log->info("Add mask for network");
			$net = NetAddr::IP->new($data->{ip_network} . '/' . $data->{ip_masklen});
			$data->{ip_mask} = $net->mask();
		} elsif ( $data->{ip_mask} && !$data->{ip_masklen} ) {
			$c->log->info("Calculating mask length");
			$net = NetAddr::IP->new($data->{ip_network}, $data->{ip_mask});
			$data->{ip_masklen} = $net->masklen();
		}
	
		if ( $data->{active} eq 'Yes' ) { $data->{active} = 1; } else { $data->{active} = 0; }
	
		$c->model('CMDBv1::IpDomainNetwork')->update_or_create( $data );
		$c->log->debug(Dumper($data));
	
		$c->response->status(HTTP_OK);
		$c->response->body('');
	} else {
		$c->response->status(HTTP_UNAUTHORIZED);
		$c->response->body('');
	}
}

sub del :Local {
	my($self, $c) = @_;
	
	if ( cmdb_check_role($c, qw/networkAdmin/) )
	{
		my($row, $network_id);
	
		$network_id = int($c->request->params->{'id'});
		$row = $c->model('CMDBv1::IpDomainNetwork')->find({ network_id => $network_id });
		if ( defined($row) ) {
			$row->delete;
		}
		$c->response->status(HTTP_OK);
		$c->response->body('');
	} else {
		$c->response->status(HTTP_UNAUTHORIZED);
		$c->response->body('');
	}
}

sub update_domain :Local {
	my($self, $c) = @_;
	
	if ( cmdb_check_role($c, qw/networkAdmin/) )
	{
		my $domain_id = $c->request->params->{domain_id};
		my $field     = $c->request->params->{field};
		my $value	  = $c->request->params->{value};
		my $domain = ActiveCMDB::Object::Ipdomain->new(domain_id => $domain_id);
		$domain->get_data();
		
		$domain->$field($value);
		$domain->save();
		$c->response->status(HTTP_OK);
	} else {
		$c->response->status(HTTP_UNAUTHORIZED);
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
