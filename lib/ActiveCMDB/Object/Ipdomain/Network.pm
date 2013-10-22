package ActiveCMDB::Object::Ipdomain::Network;

=head1 MODULE - ActiveCMDB::Object::Ipdomain::Network
    ___________________________________________________________________________

=head1 VERSION

    Version 1.0

=head1 COPYRIGHT

    Copyright (C) 2011-2015 Theo Bot

    http://www.activecmdb.org


=head1 DESCRIPTION

    Class definition

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


use 5.010;
use namespace::autoclean;
use MooseX::DeclareX
	keywords => [qw(class exception)],
	plugins  => [qw(public private)],
	types 	 => [ -Moose ]; 
	
class ActiveCMDB::Object::Ipdomain::Network with ActiveCMDB::Object::Methods
{
	use Logger;
	use NetAddr::IP;
	use Moose::Util::TypeConstraints;
	
	enum 'Proto1'  => ('md5', 'sha');
	enum 'Proto2'  => ('des', 'aes');
	
	has 'network_id' => (
		is 		=> 'ro',
		isa		=> 'Int'
	);
	
	has 'domain_id' => (
		is		=> 'rw',
		isa		=> 'Int',
		default	=> 0
	);
	
	has 'ip_network' => (
		is		=> 'rw',
		isa		=> 'Str',
		default	=> ''
	);
	
	has 'ip_mask' => (
		is		=> 'rw',
		isa		=> 'Str',
	);
	
	has 'ip_masklen' => (
		is		=> 'rw',
		isa		=> 'Int',
		default	=> 0
	);
		
	has 'active' => (
		is		=> 'rw',
		isa		=> 'Bool',
		default	=> 1
	);
	
	has 'last_update' => (
		is		=> 'rw',
		isa		=> 'Maybe[DateTime]',
	);
	
	has 'ip_order' => (
		is		=> 'rw',
		isa		=> 'Int',
		default	=> 0
	);
	
	has 'snmp_ro' => (
		is		=> 'rw',
		isa		=> 'Maybe[Str]',
	);
	
	has 'snmp_rw' => (
		is		=> 'rw',
		isa		=> 'Maybe[Str]',
	);
	
	has 'telnet_user' => (
		is		=> 'rw',
		isa		=> 'Maybe[Str]',
	);
	
	has 'telnet_pwd' => (
		is		=> 'rw',
		isa		=> 'Maybe[Str]',
	);
	
	has 'snmpv3_user' => (
		is		=> 'rw',
		isa		=> 'Maybe[Str]',
	);
	
	has 'snmpv3_pass1' => (
		is		=> 'rw',
		isa		=> 'Maybe[Str]',
	);
	
	has 'snmpv3_pass2' => (
		is		=> 'rw',
		isa		=> 'Maybe[Str]',
	);
	
	has 'snmpv3_proto1' => (
		is		=> 'rw', 
		isa		=> 'Proto1', 
		default => 'md5', 
	);

	has 'snmpv3_proto2'	=> (
		is		=> 'rw', 
		isa		=> 'Proto2', 
		default => 'aes', 
	);
	
	has 'schema' => (
		is => 'rw', 
		isa => 'Object', 
		default => sub { ActiveCMDB::Model::CMDBv1->instance() } 
	);
	
	
	
	public method get_data
	{
		my $row = $self->schema->resultset("IpDomainNetwork")->find( { network_id => $self->network_id } );
		if ( defined($row) )
		{
			foreach my $key ( __PACKAGE__->meta->get_all_attributes )
			{
				my $attr = $key->name;
				
				next if ( $attr =~ /schema|network_id/ );
				
				Logger->debug("Parsing attribute $attr");
				if ( defined($row->$attr) ) {
					$self->$attr($row->$attr);
				}
			}
		} else {
			Logger->warn("Network ID " . $self->network_id . " not found.");
		}
	}
	
	public method contains(Str $ipaddr)
	{
		my $net = new NetAddr::IP( $self->ip_network, $self->ip_mask );
		my $ip = new NetAddr::IP( $ipaddr );
		
		return $net->contains( $ip );
	}
	
};

1;