dist_epmessage | CREATE TABLE dist_epmessage (
  ep_id int(11) NOT NULL,
  subject varchar(32) NOT NULL,
  active tinyint(4) DEFAULT NULL,
  message blob,
  mimetype varchar(64) DEFAULT NULL,
  PRIMARY KEY (ep_id,subject),
  KEY fk_dist_epmessage_1_idx (ep_id),
  KEY fk_dist_epmessage_2_idx (subject),
  CONSTRAINT fk_dist_epmessage_1 FOREIGN KEY (ep_id) REFERENCES dist_endpoint (ep_id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_dist_epmessage_2 FOREIGN KEY (subject) REFERENCES dist_message (subject) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;