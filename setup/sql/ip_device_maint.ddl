CREATE TABLE `ip_device_maint` (
  `device_id` int(11) NOT NULL,
  `maint_id` int(11) NOT NULL,
  `last_cycle` bigint(20) NOT NULL DEFAULT '0',
  `tally` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`device_id`,`maint_id`),
  KEY `fk_ip_device_maint_1` (`device_id`),
  KEY `fk_ip_device_maint_2` (`maint_id`),
  CONSTRAINT `fk_ip_device_maint_1` FOREIGN KEY (`device_id`) REFERENCES `ip_device` (`device_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_ip_device_maint_2` FOREIGN KEY (`maint_id`) REFERENCES `maintenance` (`maint_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
