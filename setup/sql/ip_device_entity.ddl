CREATE TABLE `ip_device_entity` (
  `device_id` int(11) NOT NULL,
  `entPhysicalIndex` int(11) NOT NULL DEFAULT '0',
  `entPhysicalClass` smallint(6) DEFAULT NULL,
  `entPhysicalContainedIn` int(11) DEFAULT NULL,
  `entPhysicalDescr` varchar(255) DEFAULT NULL,
  `entPhysicalName` varchar(255) DEFAULT NULL,
  `entPhysicalSerialNum` varchar(64) DEFAULT NULL,
  `entPhysicalHardwareRev` varchar(32) DEFAULT NULL,
  `entPhysicalFirmwareRev` varchar(32) DEFAULT NULL,
  `entPhysicalSoftwareRev` varchar(32) DEFAULT NULL,
  `entPhysicalVendorType` varchar(256) DEFAULT NULL,
  `ifIndex` int(11) DEFAULT NULL,
  `disco` int(11) DEFAULT NULL,
  PRIMARY KEY (`device_id`,`entPhysicalIndex`),
  KEY `fk_ip_device_entity_1` (`device_id`),
  CONSTRAINT `fk_ip_device_entity_1` FOREIGN KEY (`device_id`) REFERENCES `ip_device` (`device_id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
