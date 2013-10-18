CREATE TABLE `ip_device_vrf` (
  `device_id` int(11) NOT NULL,
  `vrf_rd` varchar(45) NOT NULL,
  `vrf_name` varchar(256) DEFAULT NULL,
  `vrf_status` int(11) DEFAULT NULL,
  `disco` int(11) DEFAULT NULL,
  PRIMARY KEY (`device_id`,`vrf_rd`),
  KEY `fk_device_vrf_1` (`device_id`),
  CONSTRAINT `fk_device_vrf_1` FOREIGN KEY (`device_id`) REFERENCES `ip_device_int` (`device_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
