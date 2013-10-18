CREATE TABLE `device_log` (
  `device_log_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `device_id` int(11) DEFAULT NULL,
  `ticket_number` varchar(32) DEFAULT NULL,
  `device_log` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`device_log_id`),
  KEY `device_id` (`device_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
