package Class::Device::Snmp;

use Moose::Role;
use Net::SNMP;
use ActiveCMDB::Common::Constants;

sub snmp_get
{
	my($self, $oid) = @_;
	my($result);
	
	if ( !defined($self->comms) || ref $self->comms ne 'Net::SNMP' ) {
		$self->snmp_connect($self->attr->snmp_ro);
	} 
	
	if ( defined($self->comms) ) {
		Logger->debug("Requesting oid $oid");
		$result = $self->comms->get_request($oid);
		if ( defined($result) ) {
			Logger->debug("Request complete");
			return $result->{$oid};
		} else {
			Logger->warn("Request failed");
			return undef;
		}
	} else {
		Logger->warn("Unable to connect to device");
	}
}

sub snmp_nget
{
	my($self, @oids) = @_;
	my($result);
	
	if ( !defined($self->comms) || ref $self->comms ne 'Net::SNMP' ) {
		$self->snmp_connect($self->attr->snmp_ro);
	} 
	
	if ( defined($self->comms) ) {
		Logger->debug("Requesting oid @oids");
		$result = $self->comms->get_request(@oids);
		if ( defined($result) ) {
			Logger->debug("Request complete");
			return $result;
		} else {
			Logger->warn("Request failed");
			return undef;
		}
	} else {
		Logger->warn("Unable to connect to device");
	}
}

sub snmp_table
{
	my($self, $oid) = @_;
	my($result);
	
	#
	# Reset results
	#
	$result = undef;
	
	if ( !defined($self->comms) ) {
		Logger->debug("Communications handle not defined. Reconnecting");
		$self->snmp_connect($self->attr->snmp_ro)
	} 
	
	if ( ref $self->comms ne 'Net::SNMP' ) {
		Logger->debug("Communications handle is of type " . ref $self->comms );
		$self->snmp_connect($self->attr->snmp_ro);
	}
	
	if ( defined($self->comms) && defined($oid) ) {
		Logger->debug("Requesting table $oid");
		$result = $self->comms->get_table($oid);
		if ( defined($result) ) {
			Logger->debug("Request complete ($oid)");
			
		} else {
			Logger->warn("Request failed ($oid)")
		}
	} else {
		Logger->warn("Unable to connect to device for oid: $oid");
	}
	
	return $result;
}

sub snmp_connect
{
	my($self, $community) = @_;
	if ( $self->attr->snmpv eq '1' || $self->attr->snmpv eq '2c' )
	{
		my($result);
		my $mgtaddr = $self->attr->mgtaddress;
		my $snmpv   = $self->attr->snmpv;
		
		Logger->debug("Connecting to $mgtaddr with snmp $snmpv community $community");
		my($session, $error) = Net::SNMP->session(
									-hostname	=> $mgtaddr,
									-version	=> $snmpv,
									-community	=> $community,
									-translate	=> [ -timeticks => 0x0 ]
								);
		if ( ! defined($session) ) {
			Logger->warn("Failed to create session :$error");
			return;
		}
		$result = $session->get_request(OID_SYSOBJECTID);
		if ( !defined($result) ) {
			Logger->warn("Failed to get result :". $session->error);
			return
		}
		Logger->debug("Connection established");
		$self->comms($session);
		return true;
	}
	if ( $self->attr->snmpv eq '3' ) 
	{
		
	}
}

sub snmp_set
{
	my($self,$oid, $type, $value) = @_;

	my $res = undef;

	if ( !defined($self->comms) ) {
		Logger->debug("Communications handle not defined. Reconnecting");
		$self->snmp_connect($self->attr->snmp_rw);
	} 
	
	if ( ref $self->comms ne 'Net::SNMP' ) {
		Logger->debug("Communications handle is of type " . ref $self->comms );
		$self->snmp_connect($self->snmp_rw);
	}
	$self->comms->timeout(10);

	if ( defined($oid) && defined($value) )
	{
		Logger->debug("Setting oid: $oid with value: $value");
		$res = $self->comms->set_request($oid, $type, $value);
	}

	return $res;
}

sub snmp_error
{
	my($self) = @_;
	
	if ( ref $self->comms eq 'Net::SNMP' ) {
		return $self->comms->error();	
	}
}

1;