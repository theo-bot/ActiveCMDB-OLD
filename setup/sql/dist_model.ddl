CREATE TABLE `dist_model` (
  `model_id` int(11) NOT NULL AUTO_INCREMENT,
  `model_descr` varchar(64) DEFAULT NULL,
  `model_active` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`model_id`),
  UNIQUE KEY `model_descr_UNIQUE` (`model_descr`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;
