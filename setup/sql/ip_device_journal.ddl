CREATE TABLE `ip_device_journal` (
  `journal_id` int(11) NOT NULL AUTO_INCREMENT,
  `journal_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `device_id` int(11) NOT NULL,
  `user` varchar(16) NOT NULL,
  `journal_data` varchar(1024) DEFAULT NULL,
  `journal_prio` int(11) DEFAULT '0',
  PRIMARY KEY (`journal_id`),
  KEY `dev1` (`device_id`),
  KEY `fk_ip_device_journal_1` (`device_id`),
  CONSTRAINT `fk_ip_device_journal_1` FOREIGN KEY (`device_id`) REFERENCES `ip_device` (`device_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=113 DEFAULT CHARSET=latin1;
