CREATE TABLE `device_orders` (
  `cid` varchar(48) NOT NULL,
  `device_id` int(11) NOT NULL,
  `ts` bigint(20) NOT NULL,
  `dest` varchar(16) NOT NULL,
  PRIMARY KEY (`cid`),
  KEY `DEVKEY` (`device_id`)
) ENGINE=MEMORY DEFAULT CHARSET=latin1;
