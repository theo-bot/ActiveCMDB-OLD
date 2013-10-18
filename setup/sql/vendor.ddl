CREATE TABLE `vendor` (
  `vendor_id` int(11) NOT NULL AUTO_INCREMENT,
  `vendor_name` varchar(128) DEFAULT NULL,
  `vendor_phone` varchar(32) DEFAULT NULL,
  `vendor_support_phone` varchar(32) DEFAULT NULL,
  `vendor_support_email` varchar(256) DEFAULT NULL,
  `vendor_support_www` varchar(256) DEFAULT NULL,
  `vendor_enterprises` varchar(128) DEFAULT NULL,
  `vendor_details` text,
  PRIMARY KEY (`vendor_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
