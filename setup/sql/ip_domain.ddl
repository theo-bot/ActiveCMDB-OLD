CREATE TABLE `ip_domain` (
  `domain_id` int(11) NOT NULL,
  `domain_name` varchar(128) DEFAULT NULL,
  `active` tinyint(4) DEFAULT NULL,
  `resolvers` text,
  `auto_update` tinyint(4) DEFAULT '0',
  PRIMARY KEY (`domain_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
