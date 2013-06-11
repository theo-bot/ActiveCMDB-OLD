ip_device_mac | CREATE TABLE ip_device_mac (
  device_id int(11) NOT NULL,
  ifIndex int(11) NOT NULL,
  mac varchar(32) NOT NULL,
  disco bigint(20) DEFAULT NULL,
  PRIMARY KEY (device_id,ifIndex,mac),
  KEY CMDB0100 (device_id),
  CONSTRAINT CMDB0100 FOREIGN KEY (device_id) REFERENCES ip_device (device_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1