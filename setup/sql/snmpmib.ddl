CREATE TABLE snmpmib (
  id int(11) NOT NULL AUTO_INCREMENT,
  oid varchar(256) DEFAULT NULL,
  oidname varchar(256) DEFAULT NULL,
  type int(11) DEFAULT NULL,
  value varchar(512) DEFAULT NULL,
  mibvalue varchar(512) DEFAULT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY oid_UNIQUE (oid,value),
  UNIQUE KEY oid_name (oidname,value),
  KEY oid_type (type) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=321 DEFAULT CHARSET=latin1;