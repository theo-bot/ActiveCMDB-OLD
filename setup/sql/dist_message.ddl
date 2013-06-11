CREATE TABLE dist_message (
  subject varchar(32) NOT NULL,
  mimetype varchar(64) DEFAULT NULL,
  description varchar(64) DEFAULT NULL,
  PRIMARY KEY (subject)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;