$CMDB_HOME/bin/cmdb_snmp.pl -add -oid 1.3.6.1.2.1.1 -name system 
$CMDB_HOME/bin/cmdb_snmp.pl -add -oid 1.3.6.1.2.1.1.1.0 -name sysDescr 
$CMDB_HOME/bin/cmdb_snmp.pl -add -oid 1.3.6.1.2.1.1.2.0 -name sysObjectID 
$CMDB_HOME/bin/cmdb_snmp.pl -add -oid 1.3.6.1.2.1.1.3.0 -name sysUpTime 
$CMDB_HOME/bin/cmdb_snmp.pl -add -oid 1.3.6.1.2.1.1.5.0 -name sysName 
$CMDB_HOME/bin/cmdb_snmp.pl -add -oid 1.3.6.1.2.1.10.32.2.1.1 -name frCircuitIfIndex 
$CMDB_HOME/bin/cmdb_snmp.pl -add -oid 1.3.6.1.2.1.10.32.2.1.12 -name frCircuitCommittedBurst 
$CMDB_HOME/bin/cmdb_snmp.pl -add -oid 1.3.6.1.2.1.10.32.2.1.2 -name frCircuitDlci 
$CMDB_HOME/bin/cmdb_snmp.pl -add -oid 1.3.6.1.2.1.17.1.4.1.2 -name dot1dBasePortIfIndex 
$CMDB_HOME/bin/cmdb_snmp.pl -add -oid 1.3.6.1.2.1.17.4.3.1.1 -name dot1dTpFdbAddress 
$CMDB_HOME/bin/cmdb_snmp.pl -add -oid 1.3.6.1.2.1.17.4.3.1.2 -name dot1dTpFdbPort 
$CMDB_HOME/bin/cmdb_snmp.pl -add -oid 1.3.6.1.2.1.2.1.0 -name ifNumber 
$CMDB_HOME/bin/cmdb_snmp.pl -add -oid 1.3.6.1.2.1.2.2.1.1 -name ifIndex 
$CMDB_HOME/bin/cmdb_snmp.pl -add -oid 1.3.6.1.2.1.2.2.1.2 -name ifDescr 
$CMDB_HOME/bin/cmdb_snmp.pl -add -oid 1.3.6.1.2.1.2.2.1.3 -name ifType -value "1" -mibvalue "other"
$CMDB_HOME/bin/cmdb_snmp.pl -add -oid 1.3.6.1.2.1.2.2.1.3 -name ifType -value "2" -mibvalue "regular1822"
$CMDB_HOME/bin/cmdb_snmp.pl -add -oid 1.3.6.1.2.1.2.2.1.3 -name ifType -value "3" -mibvalue "hdh1822"
$CMDB_HOME/bin/cmdb_snmp.pl -add -oid 1.3.6.1.2.1.2.2.1.3 -name ifType -value "4" -mibvalue "ddn-x25"
$CMDB_HOME/bin/cmdb_snmp.pl -add -oid 1.3.6.1.2.1.2.2.1.3 -name ifType -value "5" -mibvalue "rfc877-x25"
$CMDB_HOME/bin/cmdb_snmp.pl -add -oid 1.3.6.1.2.1.2.2.1.3 -name ifType -value "6" -mibvalue "ethernet-csmacd"
$CMDB_HOME/bin/cmdb_snmp.pl -add -oid 1.3.6.1.2.1.2.2.1.3 -name ifType -value "7" -mibvalue "iso88023-csmacd"
$CMDB_HOME/bin/cmdb_snmp.pl -add -oid 1.3.6.1.2.1.2.2.1.3 -name ifType -value "8" -mibvalue "iso88024-tokenBus"
$CMDB_HOME/bin/cmdb_snmp.pl -add -oid 1.3.6.1.2.1.2.2.1.3 -name ifType -value "9" -mibvalue "iso88025-tokenRing"
$CMDB_HOME/bin/cmdb_snmp.pl -add -oid 1.3.6.1.2.1.2.2.1.3 -name ifType -value "10" -mibvalue "iso88026-man"
$CMDB_HOME/bin/cmdb_snmp.pl -add -oid 1.3.6.1.2.1.2.2.1.3 -name ifType -value "11" -mibvalue "starLan"
$CMDB_HOME/bin/cmdb_snmp.pl -add -oid 1.3.6.1.2.1.2.2.1.3 -name ifType -value "12" -mibvalue "proteon-10Mbit"
$CMDB_HOME/bin/cmdb_snmp.pl -add -oid 1.3.6.1.2.1.2.2.1.3 -name ifType -value "13" -mibvalue "proteon-80Mbit"
$CMDB_HOME/bin/cmdb_snmp.pl -add -oid 1.3.6.1.2.1.2.2.1.3 -name ifType -value "14" -mibvalue "hyperchannel"
$CMDB_HOME/bin/cmdb_snmp.pl -add -oid 1.3.6.1.2.1.2.2.1.3 -name ifType -value "15" -mibvalue "fddi"
$CMDB_HOME/bin/cmdb_snmp.pl -add -oid 1.3.6.1.2.1.2.2.1.3 -name ifType -value "16" -mibvalue "lapb"
$CMDB_HOME/bin/cmdb_snmp.pl -add -oid 1.3.6.1.2.1.2.2.1.3 -name ifType -value "17" -mibvalue "sdlc"
$CMDB_HOME/bin/cmdb_snmp.pl -add -oid 1.3.6.1.2.1.2.2.1.3 -name ifType -value "18" -mibvalue "ds1"
$CMDB_HOME/bin/cmdb_snmp.pl -add -oid 1.3.6.1.2.1.2.2.1.3 -name ifType -value "19" -mibvalue "e1"
$CMDB_HOME/bin/cmdb_snmp.pl -add -oid 1.3.6.1.2.1.2.2.1.3 -name ifType -value "20" -mibvalue "basicISDN"
$CMDB_HOME/bin/cmdb_snmp.pl -add -oid 1.3.6.1.2.1.2.2.1.3 -name ifType -value "21" -mibvalue "primaryISDN"
$CMDB_HOME/bin/cmdb_snmp.pl -add -oid 1.3.6.1.2.1.2.2.1.3 -name ifType -value "22" -mibvalue "propPointToPointSerial"
$CMDB_HOME/bin/cmdb_snmp.pl -add -oid 1.3.6.1.2.1.2.2.1.3 -name ifType -value "23" -mibvalue "ppp"
$CMDB_HOME/bin/cmdb_snmp.pl -add -oid 1.3.6.1.2.1.2.2.1.3 -name ifType -value "24" -mibvalue "softwareLoopback"
$CMDB_HOME/bin/cmdb_snmp.pl -add -oid 1.3.6.1.2.1.2.2.1.3 -name ifType -value "25" -mibvalue "eon"
$CMDB_HOME/bin/cmdb_snmp.pl -add -oid 1.3.6.1.2.1.2.2.1.3 -name ifType -value "26" -mibvalue "ethernet-3Mbit"
$CMDB_HOME/bin/cmdb_snmp.pl -add -oid 1.3.6.1.2.1.2.2.1.3 -name ifType -value "27" -mibvalue "nsip"
$CMDB_HOME/bin/cmdb_snmp.pl -add -oid 1.3.6.1.2.1.2.2.1.3 -name ifType -value "28" -mibvalue "slip"
$CMDB_HOME/bin/cmdb_snmp.pl -add -oid 1.3.6.1.2.1.2.2.1.3 -name ifType -value "29" -mibvalue "ultra"
$CMDB_HOME/bin/cmdb_snmp.pl -add -oid 1.3.6.1.2.1.2.2.1.3 -name ifType -value "30" -mibvalue "ds3"
$CMDB_HOME/bin/cmdb_snmp.pl -add -oid 1.3.6.1.2.1.2.2.1.3 -name ifType -value "31" -mibvalue "sip"
$CMDB_HOME/bin/cmdb_snmp.pl -add -oid 1.3.6.1.2.1.2.2.1.3 -name ifType -value "32" -mibvalue "frame-relay"
$CMDB_HOME/bin/cmdb_snmp.pl -add -oid 1.3.6.1.2.1.2.2.1.3 -name ifType 
$CMDB_HOME/bin/cmdb_snmp.pl -add -oid 1.3.6.1.2.1.2.2.1.3 -name ifType -value "53" -mibvalue "propVirtual"
$CMDB_HOME/bin/cmdb_snmp.pl -add -oid 1.3.6.1.2.1.2.2.1.5 -name ifSpeed 
$CMDB_HOME/bin/cmdb_snmp.pl -add -oid 1.3.6.1.2.1.2.2.1.6 -name ifPhysAddress 
$CMDB_HOME/bin/cmdb_snmp.pl -add -oid 1.3.6.1.2.1.2.2.1.7 -name ifAdminStatus -value "1" -mibvalue "up"
$CMDB_HOME/bin/cmdb_snmp.pl -add -oid 1.3.6.1.2.1.2.2.1.7 -name ifAdminStatus -value "2" -mibvalue "down"
$CMDB_HOME/bin/cmdb_snmp.pl -add -oid 1.3.6.1.2.1.2.2.1.7 -name ifAdminStatus -value "3" -mibvalue "testing"
$CMDB_HOME/bin/cmdb_snmp.pl -add -oid 1.3.6.1.2.1.2.2.1.7 -name ifAdminStatus 
$CMDB_HOME/bin/cmdb_snmp.pl -add -oid 1.3.6.1.2.1.2.2.1.8 -name ifOperStatus -value "1" -mibvalue "up"
$CMDB_HOME/bin/cmdb_snmp.pl -add -oid 1.3.6.1.2.1.2.2.1.8 -name ifOperStatus -value "2" -mibvalue "down"
$CMDB_HOME/bin/cmdb_snmp.pl -add -oid 1.3.6.1.2.1.2.2.1.8 -name ifOperStatus -value "3" -mibvalue "testing"
$CMDB_HOME/bin/cmdb_snmp.pl -add -oid 1.3.6.1.2.1.2.2.1.8 -name ifOperStatus 
$CMDB_HOME/bin/cmdb_snmp.pl -add -oid 1.3.6.1.2.1.2.2.1.9 -name ifLastChange 
$CMDB_HOME/bin/cmdb_snmp.pl -add -oid 1.3.6.1.2.1.3.1.1.1 -name atIfIndex 
$CMDB_HOME/bin/cmdb_snmp.pl -add -oid 1.3.6.1.2.1.3.1.1.2 -name atPhysAddress 
$CMDB_HOME/bin/cmdb_snmp.pl -add -oid 1.3.6.1.2.1.3.1.1.3 -name atNetAddress 
$CMDB_HOME/bin/cmdb_snmp.pl -add -oid 1.3.6.1.2.1.31.1.1.1.1 -name ifName 
$CMDB_HOME/bin/cmdb_snmp.pl -add -oid 1.3.6.1.2.1.31.1.1.1.15 -name ifHighSpeed 
$CMDB_HOME/bin/cmdb_snmp.pl -add -oid 1.3.6.1.2.1.31.1.1.1.18 -name ifAlias 
$CMDB_HOME/bin/cmdb_snmp.pl -add -oid 1.3.6.1.2.1.4.1 -name ipForwarding -value "1" -mibvalue "forwarding"
$CMDB_HOME/bin/cmdb_snmp.pl -add -oid 1.3.6.1.2.1.4.1 -name ipForwarding -value "2" -mibvalue "not-forwarding"
$CMDB_HOME/bin/cmdb_snmp.pl -add -oid 1.3.6.1.2.1.4.20.1.1 -name ipAdEntAddr 
$CMDB_HOME/bin/cmdb_snmp.pl -add -oid 1.3.6.1.2.1.4.20.1.2 -name ipAdEntIfIndex 
$CMDB_HOME/bin/cmdb_snmp.pl -add -oid 1.3.6.1.2.1.4.20.1.3 -name ipAdEntNetMask 
$CMDB_HOME/bin/cmdb_snmp.pl -add -oid 1.3.6.1.2.1.4.22.1.1 -name ipNetToMediaIfIndex 
$CMDB_HOME/bin/cmdb_snmp.pl -add -oid 1.3.6.1.2.1.4.22.1.2 -name ipNetToMediaPhysAddress 
$CMDB_HOME/bin/cmdb_snmp.pl -add -oid 1.3.6.1.2.1.4.22.1.3 -name ipNetToMediaNetAddress 
$CMDB_HOME/bin/cmdb_snmp.pl -add -oid 1.3.6.1.2.1.4.34.1.3.2.16 -name ipAddressIfIndex.ipv6 
$CMDB_HOME/bin/cmdb_snmp.pl -add -oid 1.3.6.1.2.1.4.34.1.5.2.16 -name ipAddressPrefix.ipv6 
$CMDB_HOME/bin/cmdb_snmp.pl -add -oid 1.3.6.1.2.1.47.1.1.1.1.1 -name entPhysicalIndex 
$CMDB_HOME/bin/cmdb_snmp.pl -add -oid 1.3.6.1.2.1.47.1.1.1.1.10 -name entPhysicalSoftwareRev 
$CMDB_HOME/bin/cmdb_snmp.pl -add -oid 1.3.6.1.2.1.47.1.1.1.1.11 -name entPhysicalSerialNum 
$CMDB_HOME/bin/cmdb_snmp.pl -add -oid 1.3.6.1.2.1.47.1.1.1.1.2 -name entPhysicalDescr 
$CMDB_HOME/bin/cmdb_snmp.pl -add -oid 1.3.6.1.2.1.47.1.1.1.1.3 -name entPhysicalVendorType 
$CMDB_HOME/bin/cmdb_snmp.pl -add -oid 1.3.6.1.2.1.47.1.1.1.1.4 -name entPhysicalContainedIn 
$CMDB_HOME/bin/cmdb_snmp.pl -add -oid 1.3.6.1.2.1.47.1.1.1.1.5 -name entPhysicalClass -value "" -mibvalue ""
$CMDB_HOME/bin/cmdb_snmp.pl -add -oid 1.3.6.1.2.1.47.1.1.1.1.5 -name entPhysicalClass -value "1" -mibvalue "other"
$CMDB_HOME/bin/cmdb_snmp.pl -add -oid 1.3.6.1.2.1.47.1.1.1.1.5 -name entPhysicalClass -value "2" -mibvalue "unknown"
$CMDB_HOME/bin/cmdb_snmp.pl -add -oid 1.3.6.1.2.1.47.1.1.1.1.5 -name entPhysicalClass -value "3" -mibvalue "chassis"
$CMDB_HOME/bin/cmdb_snmp.pl -add -oid 1.3.6.1.2.1.47.1.1.1.1.5 -name entPhysicalClass -value "4" -mibvalue "backplane"
$CMDB_HOME/bin/cmdb_snmp.pl -add -oid 1.3.6.1.2.1.47.1.1.1.1.5 -name entPhysicalClass -value "5" -mibvalue "container"
$CMDB_HOME/bin/cmdb_snmp.pl -add -oid 1.3.6.1.2.1.47.1.1.1.1.5 -name entPhysicalClass -value "6" -mibvalue "powerSupply"
$CMDB_HOME/bin/cmdb_snmp.pl -add -oid 1.3.6.1.2.1.47.1.1.1.1.5 -name entPhysicalClass -value "7" -mibvalue "fan"
$CMDB_HOME/bin/cmdb_snmp.pl -add -oid 1.3.6.1.2.1.47.1.1.1.1.5 -name entPhysicalClass -value "8" -mibvalue "sensor"
$CMDB_HOME/bin/cmdb_snmp.pl -add -oid 1.3.6.1.2.1.47.1.1.1.1.5 -name entPhysicalClass -value "9" -mibvalue "module"
$CMDB_HOME/bin/cmdb_snmp.pl -add -oid 1.3.6.1.2.1.47.1.1.1.1.5 -name entPhysicalClass -value "10" -mibvalue "port"
$CMDB_HOME/bin/cmdb_snmp.pl -add -oid 1.3.6.1.2.1.47.1.1.1.1.5 -name entPhysicalClass -value "11" -mibvalue "stack"
$CMDB_HOME/bin/cmdb_snmp.pl -add -oid 1.3.6.1.2.1.47.1.1.1.1.5 -name entPhysicalClass -value "12" -mibvalue "cpu"
$CMDB_HOME/bin/cmdb_snmp.pl -add -oid 1.3.6.1.2.1.47.1.1.1.1.5 -name entPhysicalClass 
$CMDB_HOME/bin/cmdb_snmp.pl -add -oid 1.3.6.1.2.1.47.1.1.1.1.7 -name entPhysicalName 
$CMDB_HOME/bin/cmdb_snmp.pl -add -oid 1.3.6.1.2.1.47.1.1.1.1.8 -name entPhysicalHardwareRev 
$CMDB_HOME/bin/cmdb_snmp.pl -add -oid 1.3.6.1.2.1.47.1.1.1.1.9 -name entPhysicalFirmwareRev 
$CMDB_HOME/bin/cmdb_snmp.pl -add -oid 1.3.6.1.2.1.47.1.3.2.1.1 -name entAliasLogicalIndexOrZero 
$CMDB_HOME/bin/cmdb_snmp.pl -add -oid 1.3.6.1.2.1.47.1.3.2.1.2 -name entAliasMappingIdentifier 
$CMDB_HOME/bin/cmdb_snmp.pl -add -oid 1.3.6.1.3.118.1.1.1 -name mplsVpnConfiguredVrfs 
$CMDB_HOME/bin/cmdb_snmp.pl -add -oid 1.3.6.1.3.118.1.2.1.1.2 -name mplsVpnInterfaceLabelEdgeType 
$CMDB_HOME/bin/cmdb_snmp.pl -add -oid 1.3.6.1.3.118.1.2.1.1.6 -name mplsVpnInterfaceConfRowStatus 
$CMDB_HOME/bin/cmdb_snmp.pl -add -oid 1.3.6.1.3.118.1.2.1.1.6 -name mplsVpnInterfaceConfRowStatus -value "1" -mibvalue "active"
$CMDB_HOME/bin/cmdb_snmp.pl -add -oid 1.3.6.1.3.118.1.2.1.1.6 -name mplsVpnInterfaceConfRowStatus -value "2" -mibvalue "notInService"
$CMDB_HOME/bin/cmdb_snmp.pl -add -oid 1.3.6.1.3.118.1.2.1.1.6 -name mplsVpnInterfaceConfRowStatus -value "3" -mibvalue "notReady"
$CMDB_HOME/bin/cmdb_snmp.pl -add -oid 1.3.6.1.3.118.1.2.1.1.6 -name mplsVpnInterfaceConfRowStatus -value "4" -mibvalue "createAndGo"
$CMDB_HOME/bin/cmdb_snmp.pl -add -oid 1.3.6.1.3.118.1.2.1.1.6 -name mplsVpnInterfaceConfRowStatus -value "5" -mibvalue "createAndWait"
$CMDB_HOME/bin/cmdb_snmp.pl -add -oid 1.3.6.1.3.118.1.2.1.1.6 -name mplsVpnInterfaceConfRowStatus -value "6" -mibvalue "destroy"
$CMDB_HOME/bin/cmdb_snmp.pl -add -oid 1.3.6.1.3.118.1.2.2.1.2 -name mplsVpnVrfDescription 
$CMDB_HOME/bin/cmdb_snmp.pl -add -oid 1.3.6.1.3.118.1.2.2.1.3 -name mplsVpnVrfRouteDistinguisher 
$CMDB_HOME/bin/cmdb_snmp.pl -add -oid 1.3.6.1.4.1.9.9.46.1.3.1.1.2 -name vtpVlanState 
$CMDB_HOME/bin/cmdb_snmp.pl -add -oid 1.3.6.1.4.1.9.9.46.1.3.1.1.2 -name vtpVlanState -value "1" -mibvalue "operational"
$CMDB_HOME/bin/cmdb_snmp.pl -add -oid 1.3.6.1.4.1.9.9.46.1.3.1.1.2 -name vtpVlanState -value "2" -mibvalue "suspended"
$CMDB_HOME/bin/cmdb_snmp.pl -add -oid 1.3.6.1.4.1.9.9.46.1.3.1.1.2 -name vtpVlanState -value "3" -mibvalue "mtuTooBigForDevice"
$CMDB_HOME/bin/cmdb_snmp.pl -add -oid 1.3.6.1.4.1.9.9.46.1.3.1.1.2 -name vtpVlanState -value "4" -mibvalue "mtuTooBigForTrunk"
$CMDB_HOME/bin/cmdb_snmp.pl -add -oid 1.3.6.1.4.1.9.9.46.1.3.1.1.3 -name vtpVlanType 
$CMDB_HOME/bin/cmdb_snmp.pl -add -oid 1.3.6.1.4.1.9.9.46.1.3.1.1.3 -name vtpVlanType -value "1" -mibvalue "ethernet"
$CMDB_HOME/bin/cmdb_snmp.pl -add -oid 1.3.6.1.4.1.9.9.46.1.3.1.1.3 -name vtpVlanType -value "2" -mibvalue "fddi"
$CMDB_HOME/bin/cmdb_snmp.pl -add -oid 1.3.6.1.4.1.9.9.46.1.3.1.1.3 -name vtpVlanType -value "3" -mibvalue "tokenRing"
$CMDB_HOME/bin/cmdb_snmp.pl -add -oid 1.3.6.1.4.1.9.9.46.1.3.1.1.3 -name vtpVlanType -value "4" -mibvalue "fddiNet"
$CMDB_HOME/bin/cmdb_snmp.pl -add -oid 1.3.6.1.4.1.9.9.46.1.3.1.1.3 -name vtpVlanType -value "5" -mibvalue "trNet"
$CMDB_HOME/bin/cmdb_snmp.pl -add -oid 1.3.6.1.4.1.9.9.46.1.3.1.1.3 -name vtpVlanType -value "6" -mibvalue "deprecated"
$CMDB_HOME/bin/cmdb_snmp.pl -add -oid 1.3.6.1.4.1.9.9.46.1.3.1.1.4 -name vtpVlanName 
$CMDB_HOME/bin/cmdb_snmp.pl -add -oid 1.3.6.1.4.1.9.9.46.1.6.1.1.14 -name vlanTrunkPortDynamicStatus 
$CMDB_HOME/bin/cmdb_snmp.pl -add -oid 1.3.6.1.4.1.9.9.49.1.2.2.1.13 -name cfrExtCircuitMinThruputOut 
$CMDB_HOME/bin/cmdb_snmp.pl -add -oid 1.3.6.1.4.1.9.9.49.1.2.2.1.2 -name cfrExtCircuitIfType 
$CMDB_HOME/bin/cmdb_snmp.pl -add -oid 1.3.6.1.4.1.9.9.49.1.2.2.1.2 -name cfrExtCircuitIfType -value "1" -mibvalue "mainInterface"
$CMDB_HOME/bin/cmdb_snmp.pl -add -oid 1.3.6.1.4.1.9.9.49.1.2.2.1.2 -name cfrExtCircuitIfType -value "2" -mibvalue "pointToPoint"
$CMDB_HOME/bin/cmdb_snmp.pl -add -oid 1.3.6.1.4.1.9.9.49.1.2.2.1.2 -name cfrExtCircuitIfType -value "3" -mibvalue "multipoint"
$CMDB_HOME/bin/cmdb_snmp.pl -add -oid 1.3.6.1.4.1.9.9.49.1.2.2.1.3 -name cfrExtCircuitSubifIndex 
$CMDB_HOME/bin/cmdb_snmp.pl -add -oid 1.3.6.1.4.1.9.9.68.1.2.2.1.2 -name vmVlan 
