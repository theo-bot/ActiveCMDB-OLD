CREATE TABLE `security` (
  `security_id` int(11) NOT NULL AUTO_INCREMENT,
  `security_name` varchar(32) DEFAULT NULL,
  `security_user` varchar(32) DEFAULT NULL,
  `security_pwd` varchar(128) DEFAULT NULL,
  `security_key` varchar(1024) DEFAULT NULL,
  PRIMARY KEY (`security_id`),
  UNIQUE KEY `sec_name` (`security_name`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;