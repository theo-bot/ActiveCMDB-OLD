CREATE TABLE ip_device_at (
  device_id int(11) NOT NULL,
  atIfIndex int(11) DEFAULT NULL,
  atPhysAddress varchar(32) NOT NULL,
  atNetAddress varchar(256) NOT NULL,
  disco bigint(20) DEFAULT NULL,
  PRIMARY KEY (device_id,atPhysAddress,atNetAddress),
  KEY fk_ip_device_at_1 (device_id),
  CONSTRAINT fk_ip_device_at_1 FOREIGN KEY (device_id) REFERENCES ip_device (device_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;