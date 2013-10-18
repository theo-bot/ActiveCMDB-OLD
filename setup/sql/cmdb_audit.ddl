CREATE TABLE `cmdb_audit` (
  `object_id` bigint(20) NOT NULL,
  `audit_seq` bigint(20) NOT NULL AUTO_INCREMENT,
  `object_type` varchar(128) DEFAULT NULL,
  `audit_date` timestamp NULL DEFAULT NULL,
  `audit_user` varchar(32) DEFAULT NULL,
  `audit_type` int(11) DEFAULT NULL,
  `audit_descr` varchar(1024) DEFAULT NULL,
  PRIMARY KEY (`audit_seq`,`object_id`),
  KEY `CMDB0100` (`object_id`,`object_type`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=latin1;
