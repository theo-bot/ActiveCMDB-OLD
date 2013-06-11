CREATE TABLE ip_config_data (
  config_id varchar(48) NOT NULL,
  device_id int(11) DEFAULT NULL,
  config_date bigint(20) DEFAULT NULL,
  config_checksum varchar(45) DEFAULT NULL,
  config_status int(11) DEFAULT NULL,
  config_type varchar(16) DEFAULT NULL,
  config_name varchar(45) DEFAULT NULL,
  PRIMARY KEY (config_id),
  KEY CMDB0023 (device_id),
  KEY CMDB0024 (device_id,config_name,config_checksum)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;