CREATE TABLE `ip_device_type_image` (
  `type_id` int(11) NOT NULL,
  `mime_type` varchar(64) DEFAULT NULL,
  `image` blob,
  PRIMARY KEY (`type_id`),
  KEY `fk_ip_device_type_image_1` (`type_id`),
  CONSTRAINT `fk_ip_device_type_image_1` FOREIGN KEY (`type_id`) REFERENCES `ip_device_type` (`type_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
