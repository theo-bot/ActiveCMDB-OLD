CREATE TABLE server (
  id int(11) NOT NULL,
  servername varchar(64) NOT NULL,
  netaddr varchar(128) NOT NULL,
  active tinyint(4) NOT NULL,
  master tinyint(4) NOT NULL DEFAULT '0',
  UNIQUE KEY id_UNIQUE (id),
  UNIQUE KEY servername_UNIQUE (servername),
  UNIQUE KEY netaddr_UNIQUE (netaddr)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;