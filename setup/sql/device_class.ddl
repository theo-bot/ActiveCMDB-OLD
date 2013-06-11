CREATE TABLE device_class (
  class_id int(11) NOT NULL,
  Name varchar(16) DEFAULT NULL,
  SuperClass varchar(16) DEFAULT NULL,
  Enabled tinyint(4) DEFAULT NULL,
  Revision int(11) DEFAULT NULL,
  PRIMARY KEY (class_id),
  KEY idx_name (Name),
  KEY idx_class_enabled (Enabled)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;