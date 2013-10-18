CREATE TABLE `ip_device_int_dlci` (
  `device_id` int(11) NOT NULL,
  `ifIndex` int(11) NOT NULL,
  `dlci` int(11) NOT NULL,
  `minCir` int(11) DEFAULT NULL,
  `maxBurst` int(11) DEFAULT NULL,
  `type` varchar(32) DEFAULT NULL,
  `disco` int(11) DEFAULT NULL,
  PRIMARY KEY (`ifIndex`,`device_id`,`dlci`),
  KEY `fk_ip_device_int_dlci_1_idx` (`device_id`,`ifIndex`),
  CONSTRAINT `fk_ip_device_int_dlci_1` FOREIGN KEY (`device_id`, `ifIndex`) REFERENCES `ip_device_int` (`device_id`, `ifIndex`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
