package Class::Device;

use Methods;
use Moose;
use ActiveCMDB::Schema;
use ActiveCMDB::Model::CMDBv1;
use ActiveCMDB::Object::Device;
use Logger;

has 'device_id'		=> ( is => 'ro', isa => 'Int' );
has 'attr'		=> ( is => 'rw', isa => 'Object' );

#
# Comms is communications handle
#
has 'comms'			=> ( is => 'rw');

with 'Methods';
with 'Class::Device::Icmp';
with 'Class::Device::Snmp';
with 'Class::Device::System';
with 'Class::Device::Interface';
with 'Class::Device::Arp';
with 'Class::Device::Ipmib';
with 'Class::Device::Entity';
with 'Class::Device::TcpServices';
with 'Class::Device::BridgeMib';

sub get_data
{
	my($self) = @_;
	my($rs);
	
	Logger->info("Getting object data for object type ".ref $self);
	
	$self->attr( ActiveCMDB::Object::Device->new( device_id => $self->device_id ) );
	$self->attr->find();
	
}

sub get_oid_by_name {
	my($self, $name) = @_;
	my($rs, $oid);
	
	if ( defined($name) ) {
		$rs = $self->attr->schema->resultset("Snmpmib")->search(
			{
			 	oidname => $name 
			}, 
			{
				columns => [qw/ oid /]
			})->next;
		if ( defined($rs)) {
			return $rs->oid;
		}
	}
}

sub set_disco {
	my($self, $dtime) = @_;
	
	if ( defined($dtime) )
	{
		$self->attr->discotime($dtime);
		$self->attr->save();
	}
}

__PACKAGE__->meta->make_immutable;
1;