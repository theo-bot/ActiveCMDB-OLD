package Class::Cisco::FrameRelay;


=head1 MODULE - Class::Cisco::FrameRelay.pm
    ___________________________________________________________________________

=head1 VERSION

    Version 1.0

=head1 COPYRIGHT

    Copyright (C) 2011-2015 Theo Bot

    http://www.activecmdb.org


=head1 DESCRIPTION

    Discovery Object to interrogate devices for Frame Relay Circuits

	1.3.6.1.4.1.9.9.49.1.2.2.1.3		=>	cfrExtCircuitSubifIndex
										.1.3.6.1.4.1.9.9.49.1.2.2.1.3.6.100 = INTEGER: 8
									   	
	1.3.6.1.4.1.9.9.49.1.2.2.1.2		=>	cfrExtCircuitIfType
										.1.3.6.1.4.1.9.9.49.1.2.2.1.2.6.100 = INTEGER: 2
										1 : mainInterface
										2 : pointToPoint
										3 : multipoint

	1.3.6.1.2.1.10.32.2.1.1			=>	frCircuitIfIndex
										.1.3.6.1.2.1.10.32.2.1.1.6.100 = INTEGER: 6

	1.3.6.1.2.1.10.32.2.1.2			=>	frCircuitDlci
										.1.3.6.1.2.1.10.32.2.1.2.6.100 = INTEGER: 100

 										
	1.3.6.1.2.1.10.32.2.1.12			=>	frCircuitCommittedBurst
										.1.3.6.1.2.1.10.32.2.1.12.6.100 = INTEGER: 47500

	1.3.6.1.4.1.9.9.49.1.2.2.1.13		=>	cfrExtCircuitMinThruputOut
										.1.3.6.1.4.1.9.9.49.1.2.2.1.13.6.100 = INTEGER: 4750000
										bits/s

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

use Moose::Role;
use Try::Tiny;
use Data::Dumper;
use Switch;
use Logger;
use ActiveCMDB::Common::Constants;
use ActiveCMDB::Common::Conversion;
use ActiveCMDB::Object::Circuit::FrDlci;

my %snmp_objectmap = (
	cfrExtCircuitSubifIndex		=> 'SubifIndex',
	cfrExtCircuitIfType			=> 'type',
	frCircuitCommittedBurst		=> 'burst',
	cfrExtCircuitMinThruputOut	=> 'mincir'
);

sub discover_ciscoFrameRelay
{
	my($self, $data) = @_;
	my($oid, $res,$object,$ifIndex,$value, $snmp_oid, $result);
	my @index = ();
	my %ifDlci = ();
	
	$result = undef;
	
	# Get all indexes on which a dlci was configured
	$snmp_oid = $self->get_oid_by_name('frCircuitIfIndex');
	$res = $self->snmp_table($snmp_oid);
	if ( defined($res) )
	{
		#
		# Import dlci types
		#
		my %circuitType = cmdb_oid_set('cfrExtCircuitIfType');
		
		foreach $oid ( keys %{$res} )
		{
			push(@index, $res->{$oid});
		}
		
		# Get all dlci's on the configured interfaces
		foreach $ifIndex (@index)
		{
			$snmp_oid = $self->get_oid_by_name('frCircuitDlci') . '.' . $ifIndex;
			$res = $self->snmp_table($snmp_oid);
			foreach $oid (keys %{$res} )
			{
				my $key = '.' . $ifIndex . '.' . $res->{$oid};
				$ifDlci{$key} = 1;
				$result->{$key}->{ifIndex} = $ifIndex;
				$result->{$key}->{dlci}	= $res->{$oid};
				$result->{$key}->{disco} = $data->{system}->disco;
			}
		}
		Logger->debug("Fetching dlci data per ifIndex/dlci");
		foreach my $key (keys %ifDlci)
		{
			foreach $object (keys %snmp_objectmap)
			{
				$snmp_oid = $self->get_oid_by_name($object) . $key;
				Logger->debug("Fetching $object :: $snmp_oid");
				$res = $self->snmp_get($snmp_oid);
				if ( defined($res) ) {
					switch( $object )
					{
						case 'cfrExtCircuitIfType'	{ 
							Logger->debug("Translating $res into " . $circuitType{$res} );
							$result->{$key}->{ $snmp_objectmap{$object} } = $circuitType{$res};
						}
						else { 
							$result->{$key}->{ $snmp_objectmap{$object} } = $res;
						}	
					}
				}
			}
		}
		
		
	} else {
		Logger->info("No frame-relay dlci's configured");
	}
	Logger->debug(Dumper($result));
	
	return $result;
}

sub save_ciscoFrameRelay
{
	my($self, $data) = @_;
	my ($result, $disco);
	
	my $transaction = sub {
		foreach my $key (keys %{$data})
		{
			my $dlci = ActiveCMDB::Object::Circuit::FrDlci->new(
				device_id		=> $self->attr->device_id,
				ifindex			=> $data->{$key}->{SubifIndex},
				dlci			=> $data->{$key}->{dlci}
			);
			$dlci->get_data();
			$dlci->cir( $data->{$key}->{mincir} );
			$dlci->burst( $data->{$key}->{burst} );
			$dlci->type( $data->{$key}->{type} );
			$dlci->disco( $data->{$key}->{disco} );
			if ( !defined($disco) ) { $disco = $dlci->disco; }
			$dlci->save();
		}
		
		my $rs = $self->attr->schema->resultset("IpDeviceIntDlci")->search(
			{
				device_id	=> $self->attr->device_id,
				disco		=> { '!=' => $disco }
			}
		);
		
		if ( defined($rs) ) {
			while ( my $row = $rs->next ) 
			{
				$row->delete();
			}
		}
	};
	
	Logger->debug("Saving Frame-Relay data");
	try {
		$result = $self->attr->schema->txn_do( $transaction );
	} catch {
		Logger->error("Failed to save frame-relay data: " . $_);
	};
}

1;


