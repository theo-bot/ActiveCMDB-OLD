CREATE TABLE `cmdb_menu` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `label` varchar(32) NOT NULL,
  `icon` varchar(64) DEFAULT NULL,
  `active` tinyint(4) NOT NULL DEFAULT '1',
  `children` text,
  `url` text,
  PRIMARY KEY (`id`),
  UNIQUE KEY `label_UNIQUE` (`label`)
) ENGINE=MyISAM  DEFAULT CHARSET=latin1;
