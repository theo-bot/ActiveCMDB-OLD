CREATE TABLE ip_config_object (
  config_id varchar(48) NOT NULL,
  config_data blob,
  PRIMARY KEY (config_id),
  KEY CMDBFK0020 (config_id),
  CONSTRAINT CMDBFK0020 FOREIGN KEY (config_id) REFERENCES ip_config_data (config_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;