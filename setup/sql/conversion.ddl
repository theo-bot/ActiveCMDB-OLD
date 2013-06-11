CREATE TABLE conversion (
  id int(11) NOT NULL AUTO_INCREMENT,
  name varchar(64) DEFAULT NULL,
  value varchar(255) DEFAULT NULL,
  conversion varchar(255) DEFAULT NULL,
  PRIMARY KEY (id),
  KEY search (name,value)
) ENGINE=InnoDB AUTO_INCREMENT=337 DEFAULT CHARSET=latin1;