CREATE TABLE `ip_device_int` (
  `device_id` int(11) NOT NULL,
  `ifIndex` int(11) NOT NULL,
  `ifType` int(11) DEFAULT NULL,
  `ifDescr` varchar(64) DEFAULT NULL,
  `ifName` varchar(64) DEFAULT NULL,
  `ifSpeed` bigint(20) DEFAULT NULL,
  `ifAdminStatus` tinyint(4) DEFAULT NULL,
  `ifOperStatus` tinyint(4) DEFAULT NULL,
  `ifAlias` varchar(128) DEFAULT NULL,
  `cable_id` int(11) DEFAULT '0',
  `ifPhysAddress` varchar(32) DEFAULT NULL,
  `ifHighSpeed` bigint(20) DEFAULT '0',
  `ifLastChange` bigint(20) DEFAULT '0',
  `isTrunk` smallint(6) DEFAULT '0',
  `disco` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`device_id`,`ifIndex`),
  KEY `CMDB0003` (`ifIndex`),
  KEY `CMDB0001` (`device_id`),
  CONSTRAINT FK_CMDB002 FOREIGN KEY (`device_id`) REFERENCES `ip_device` (`device_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
