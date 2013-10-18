CREATE TABLE `ip_device_sec` (
  `device_id` int(11) NOT NULL,
  `telnet_user` varchar(32) DEFAULT NULL,
  `telnet_pwd` varchar(16) DEFAULT NULL,
  `snmpv` int(11) DEFAULT '1',
  `snmp_ro` varchar(32) DEFAULT NULL,
  `snmp_rw` varchar(32) DEFAULT NULL,
  `snmpv3_user` varchar(16) DEFAULT NULL,
  `snmpv3_pass1` varchar(64) DEFAULT NULL,
  `snmpv3_pass2` varchar(64) DEFAULT NULL,
  `snmpv3_proto1` varchar(8) DEFAULT NULL,
  `snmpv3_proto2` varchar(8) DEFAULT NULL,
  `snmp_port` int(11) DEFAULT '161',
  PRIMARY KEY (`device_id`),
  KEY `fk_device_sec_1` (`device_id`),
  CONSTRAINT `fk_device_sec_1` FOREIGN KEY (`device_id`) REFERENCES `ip_device` (`device_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
