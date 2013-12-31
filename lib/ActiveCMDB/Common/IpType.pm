package ActiveCMDB::Common::IpType;

use Exporter;
use Logger;
use ActiveCMDB::Common::Constants;
use ActiveCMDB::Object::IpType;
use ActiveCMDB::Model::CMDBv1;
use Try::Tiny;
use strict;
use Data::Dumper;

our @ISA = ('Exporter');

our @EXPORT = qw(
	get_iptype_by_typeid
	get_disco_schemes
);

sub get_iptype_by_typeid
{
	my($type_id) = @_;
	
	
	if ( defined($type_id) )
	{
		my $schema = ActiveCMDB::Model::CMDBv1->instance();
	
		my $row = $schema->resultset("IpDeviceType")->find(
						{
							type_id => $type_id
						},
						{
							columns	=> 'sysobjectid'
						}
					);
		if ( defined($row) )
		{
			my $iptype = ActiveCMDB::Object::IpType->new(sysobjectid => $row->sysobjectid);
			$iptype->get_data();
			
			return $iptype;
		}
	}
}

sub get_disco_schemes
{
	my @schemes = ();
	my $schema = ActiveCMDB::Model::CMDBv1->instance();
	my $rs = $schema->resultset("DiscoScheme")->search(
				{
				},
				{
					columns	 => [ qw/scheme_id name/ ],
					order_by => 'scheme_id'
				}
	);
	
	if ( defined($rs) )
	{
		while( my $row = $rs->next )
		{
			push(@schemes, { scheme_id => $row->scheme_id, name => $row->name });
		}
	}
	
	return @schemes;
}