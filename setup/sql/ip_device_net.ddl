CREATE TABLE `ip_device_net` (
  `device_id` int(11) NOT NULL,
  `ipAdEntIfIndex` int(11) DEFAULT NULL,
  `iptype` int(11) DEFAULT NULL,
  `ipAdEntAddr` varchar(256) NOT NULL,
  `ipAdEntNetMask` varchar(256) DEFAULT NULL,
  `disco` bigint(20) DEFAULT NULL,
  `ipAdEntPrefix` int(11) DEFAULT NULL,
  PRIMARY KEY (`device_id`,`ipAdEntAddr`),
  KEY `fk_device_net_1` (`device_id`,`ipAdEntIfIndex`),
  CONSTRAINT `fk_device_net_1` FOREIGN KEY (`device_id`, `ipAdEntIfIndex`) REFERENCES `ip_device_int` (`device_id`, `ifIndex`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
