package ActiveCMDB::Common::ObjectOrders;

use Exporter;
use Logger;
use ActiveCMDB::Object::ObjectOrder;
use ActiveCMDB::Model::CMDBv1;
use Try::Tiny;
use strict;
use Data::Dumper;

our @ISA = ('Exporter');

our @EXPORT = qw(
	cmdb_get_object_orders
	cmdb_count_object_orders
);

my $schema = ActiveCMDB::Model::CMDBv1->instance();

sub cmdb_get_object_orders
{
	
	my @orders = ();
	
	my $rs = $schema->resultset('DeviceOrder')->search(undef, { columns => qw/cid/ });
	if ( defined($rs) )
	{
		while( my $row = $rs->next )
		{
			my $order = ActiveCMDB::Object::ObjectOrder->new(cid => $row->cid);
			if ( $order->get_data() )
			{
				push(@orders, $order);
			}
		}
	}
	
	return @orders;
}

sub cmdb_count_object_orders
{
	my(@dests) = @_;
	
	return $schema->resultset('DeviceOrder')->count({
		dest => { -in => [ @dests ]}
	});
}