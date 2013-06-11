CREATE TABLE ip_device_vrf (
  device_id int(11) NOT NULL,
  ifIndex int(11) NOT NULL,
  vrf_rd varchar(45) NOT NULL,
  vrf_name varchar(256) DEFAULT NULL,
  PRIMARY KEY (device_id,ifIndex,vrf_rd),
  KEY fk_device_vrf_1 (device_id,ifIndex),
  CONSTRAINT fk_device_vrf_1 FOREIGN KEY (device_id, ifIndex) REFERENCES ip_device_int (device_id, ifIndex) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=latin1;