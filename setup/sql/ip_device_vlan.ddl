CREATE TABLE `ip_device_vlan` (
  `device_id` int(11) NOT NULL,
  `vlan_id` int(11) NOT NULL,
  `name` varchar(128) DEFAULT NULL,
  `status` varchar(32) DEFAULT NULL,
  `disco` int(11) DEFAULT NULL,
  PRIMARY KEY (`device_id`,`vlan_id`),
  KEY `fk_ip_device_vlan_1_idx` (`device_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
