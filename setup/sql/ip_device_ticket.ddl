CREATE TABLE ip_device_ticket (
  device_id int(11) NOT NULL,
  ticket_id varchar(32) NOT NULL,
  source varchar(64) DEFAULT NULL,
  date_open bigint(20) DEFAULT NULL,
  date_closed bigint(20) DEFAULT NULL,
  description varchar(1024) DEFAULT NULL,
  PRIMARY KEY (device_id,ticket_id),
  KEY fk_ip_device_ticket_1 (device_id)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;