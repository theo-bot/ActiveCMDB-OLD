CREATE TABLE disco_schemes (
  scheme_id int(11) NOT NULL AUTO_INCREMENT,
  name varchar(32) DEFAULT NULL,
  active tinyint(1) NOT NULL DEFAULT '1',
  block1 varchar(32) DEFAULT NULL,
  block2 varchar(32) DEFAULT NULL,
  PRIMARY KEY (scheme_id)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;