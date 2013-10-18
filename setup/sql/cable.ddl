CREATE TABLE `cable` (
  `device_id` int(11) NOT NULL,
  `cable_id` varchar(32) NOT NULL,
  `cable_type` int(11) NOT NULL,
  `cable_con_a` int(11) DEFAULT NULL,
  `cable_con_b` int(11) DEFAULT NULL,
  PRIMARY KEY (`device_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
