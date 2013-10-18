CREATE TABLE `ip_device_int_vrf` (
  `device_id` int(11) NOT NULL,
  `ifIndex` int(11) NOT NULL,
  `vrf_rd` varchar(45) NOT NULL DEFAULT '',
  `disco` int(11) DEFAULT NULL,
  PRIMARY KEY (`device_id`,`ifIndex`,`vrf_rd`),
  KEY `fk_ip_device_int_vrf_1_idx` (`vrf_rd`),
  KEY `fk_ip_device_int_vrf_1` (`device_id`,`vrf_rd`),
  CONSTRAINT `fk_ip_device_int_vrf_1` FOREIGN KEY (`device_id`, `vrf_rd`) REFERENCES `ip_device_vrf` (`device_id`, `vrf_rd`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_ip_device_int_vrf_2` FOREIGN KEY (`device_id`, `ifIndex`) REFERENCES `ip_device_int` (`device_id`, `ifIndex`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
