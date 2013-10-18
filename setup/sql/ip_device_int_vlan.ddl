CREATE TABLE `ip_device_int_vlan` (
  `device_id` int(11) NOT NULL,
  `ifIndex` int(11) NOT NULL,
  `vlan_id` int(11) NOT NULL,
  `disco` int(11) DEFAULT NULL,
  PRIMARY KEY (`device_id`,`ifIndex`),
  KEY `fk_ip_device_vlan_1` (`device_id`,`ifIndex`),
  CONSTRAINT `fk_ip_device_vlan_1` FOREIGN KEY (`device_id`, `ifIndex`) REFERENCES `ip_device_int` (`device_id`, `ifIndex`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
