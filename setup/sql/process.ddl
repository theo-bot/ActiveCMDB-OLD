CREATE TABLE `process` (
  `process_instance` int(11) NOT NULL,
  `process_name` varchar(16) NOT NULL,
  `process_server` int(11) NOT NULL,
  `process_status` int(11) DEFAULT NULL,
  `process_pid` int(11) DEFAULT NULL,
  `process_parent` int(11) DEFAULT NULL,
  `process_type` varchar(16) DEFAULT NULL,
  `process_path` varchar(256) DEFAULT NULL,
  `process_comms` varchar(256) DEFAULT NULL,
  `process_order` int(11) DEFAULT NULL,
  `process_update` bigint(20) DEFAULT NULL,
  `process_start` bigint(20) DEFAULT NULL,
  `process_data` text,
  `updated_by` varchar(64) DEFAULT NULL,
  PRIMARY KEY (`process_name`,`process_server`,`process_instance`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
