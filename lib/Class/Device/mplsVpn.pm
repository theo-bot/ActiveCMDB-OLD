package Class::Device::mplsVpn;

=begin nd

    Script: CMDB::Device::mplsVpn.pm
    ___________________________________________________________________________

    Version 1.0

    Copyright (C) 2013-2015 Theo Bot

    http://www.activecmdb.org


    Topic: Purpose

    Class::Device::mplsVpn class definition

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

=cut

use Moose::Role;
use Data::Dumper;
use Try::Tiny;
use Logger;
use ActiveCMDB::Common::Constants;
use ActiveCMDB::Object::Circuit::MplsVpn;

my %vars	= (	
				
				'mplsVpnVrfDescription'				=> 1,
				'mplsVpnInterfaceConfRowStatus'		=> 1,
				'mplsVpnVrfRouteDistinguisher'		=> 1,
				'mplsVpnInterfaceLabelEdgeType'		=> 1
				);

=item discover_mplsVpn

Discover mplsVpn mib

=cut

sub discover_mplsVpn
{
	my($self,$data) = @_;
	my($res,$object,$oid,$oid1,$ifIndex,$key,$vpnname, $baseoid);
	my %vpns = ();
	my $intvrf = undef;
	
	$baseoid = $self->get_oid_by_name('mplsVpnConfiguredVrfs');
	$oid = $baseoid.'.0';
	
	$res = $self->snmp_get($oid);
	Logger->debug("Got $res from snmp_get");
	if ( defined($res) ) 
	{
		if ( $res > 0 )
		{
			foreach $object (keys %vars)
			{
				$oid1 = $self->get_oid_by_name( $object );
				$res = $self->snmp_table( $oid1 );
				if ( defined($res) )
				{
					foreach $key (keys %{$res}) 
					{
						my $k = _oidkey($oid1, $key);
						$vpnname = _oid_to_vrf($k);
						Logger->debug("$k => $vpnname");
						my @help = split(/\./,$k);
						$ifIndex = pop(@help);
						
						if ( $object eq 'mplsVpnInterfaceLabelEdgeType' ) 
						{
							#$intvrf->{int}->{$ifIndex}->{name} = $vpnname;
							push(@{$intvrf->{vrf}->{$vpnname}->{int}}, $ifIndex);
						}
						if ( $object eq 'mplsVpnInterfaceConfRowStatus' )
						{
							$intvrf->{vrf}->{$vpnname}->{disco} = $data->{system}->disco;
							$intvrf->{vrf}->{$vpnname}->{status} = $res->{$key}; 
						}
						if ( $object eq 'mplsVpnVrfDescription' )
						{
							$intvrf->{vrf}->{$vpnname}->{descr} = $res->{$key};
						}
						if ( $object eq 'mplsVpnVrfRouteDistinguisher' ) 
						{
							$intvrf->{vrf}->{$vpnname}->{rd} = $res->{$key};	
						}
					}
				} else {
					Logger->warn("Failed to read table $object")
				}
			} # Ends foreach
			
		} else {
			Logger->info("No vpns configured");
		}
	} else {
		Logger->warn("Failed to read snmp table mplsVpnConfiguredVrfs")
	}
	
	Logger->debug(Dumper($intvrf));
	return $intvrf;
}

sub save_mplsVpn
{
	my($self,$data) = @_;
	
	foreach my $vpnname (keys %{$data->{vrf}})
	{
		my $vpn = ActiveCMDB::Object::Circuit::MplsVpn->new(
						device_id	=> $self->attr->device_id,
						rd			=> $data->{vrf}->{$vpnname}->{rd},
						name		=> $vpnname,
						status		=> $data->{vrf}->{$vpnname}->{status},
						disco		=> $data->{vrf}->{$vpnname}->{disco}
					);
		$vpn->save();
		$vpn->interfaces(@{$data->{vrf}->{$vpnname}->{int}});
	}
}

sub _oid_to_vrf
{
        my($oid) = @_;
        my $vrfid = '';
        my @chars = split(/\./,$oid);
        foreach (@chars)
        {
                if ( $_ > 47 && $_ < 127 ) { $vrfid .= chr($_); }
        }
        $vrfid =~ s/^.*://;
        return($vrfid);
}

sub _oidkey {
	my($baseoid, $oid) = @_;
	my @b = split(/\./, $baseoid);
	my @o = split(/\./, $oid);
	splice(@o, 0, $#b + 1);
	return join('.', @o);
}

1;