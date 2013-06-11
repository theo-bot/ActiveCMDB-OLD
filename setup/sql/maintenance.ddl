CREATE TABLE maintenance (
  maint_id int(11) NOT NULL AUTO_INCREMENT,
  start_date bigint(20) DEFAULT NULL,
  end_date bigint(20) DEFAULT NULL,
  start_time int(11) DEFAULT NULL,
  end_time int(11) DEFAULT NULL,
  m_repeat int(11) DEFAULT '0',
  m_interval int(11) DEFAULT '0',
  descr varchar(64) NOT NULL,
  PRIMARY KEY (maint_id)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=latin1;