CREATE TABLE config_ruleset (
	set_id			INTEGER NOT NULL AUTO_INCREMENT,
	active			TINYINT NOT NULL DEFAULT '0',
	policy_id		INTEGER,
	network_type	INTEGER,
	vendor_id		INTEGER,
	last_update		BIGINT NOT NULL DEFAULT '0',
	updated_by		VARCHAR(32) NOT NULL,
	description		TEXT,
	PRIMARY KEY(set_id),
) Engine=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO config_ruleset VALUES(0,0,0,0,0,"Global Set");