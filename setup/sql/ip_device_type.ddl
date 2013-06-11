CREATE TABLE ip_device_type (
  type_id int(11) NOT NULL AUTO_INCREMENT,
  descr varchar(32) DEFAULT NULL,
  sysObjectID varchar(128) DEFAULT NULL,
  disco_model int(11) DEFAULT NULL,
  active tinyint(4) DEFAULT NULL,
  vendor_id int(11) DEFAULT NULL,
  networkType int(11) NOT NULL DEFAULT '1',
  class int(11) DEFAULT '1',
  disco_scheme int(11) DEFAULT NULL,
  ObjectClass varchar(256) DEFAULT NULL,
  PRIMARY KEY (type_id),
  UNIQUE KEY sysObjectID_UNIQUE (sysObjectID),
  KEY disco_id (disco_model)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1 COMMENT='Device types';