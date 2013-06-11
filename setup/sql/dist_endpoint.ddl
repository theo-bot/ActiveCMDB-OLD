CREATE TABLE dist_endpoint (
  ep_id int(11) NOT NULL AUTO_INCREMENT,
  ep_name varchar(32) DEFAULT NULL,
  ep_method varchar(8) DEFAULT NULL,
  ep_active tinyint(1) DEFAULT '1',
  ep_dest_in varchar(1024) DEFAULT NULL,
  ep_dest_out varchar(1024) DEFAULT NULL,
  ep_user varchar(16) DEFAULT NULL,
  ep_encrypt int(11) DEFAULT NULL,
  ep_password varchar(1024) DEFAULT NULL,
  ep_dest_key varchar(1024) DEFAULT NULL,
  ep_network_data varchar(128) DEFAULT NULL,
  PRIMARY KEY (ep_id),
  UNIQUE KEY ep_name_UNIQUE (ep_name)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=latin1 COMMENT='Distribution endpoints';