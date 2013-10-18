CREATE TABLE `contracts` (
  `contract_id` int(11) NOT NULL AUTO_INCREMENT,
  `contract_number` varchar(32) DEFAULT NULL,
  `contract_descr` varchar(32) DEFAULT NULL,
  `vendor_id` int(11) DEFAULT NULL,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `service_hours` varchar(32) DEFAULT NULL,
  `internal_phone` varchar(32) DEFAULT NULL,
  `internal_contact` varchar(64) DEFAULT NULL,
  `contract_details` text,
  PRIMARY KEY (`contract_id`),
  UNIQUE KEY `CMDB110801` (`contract_number`),
  KEY `idxvendor` (`vendor_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
