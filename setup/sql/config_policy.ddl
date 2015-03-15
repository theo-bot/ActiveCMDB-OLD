CREATE TABLE config_policy (
	policy_id	INTEGER NOT NULL AUTO_INCREMENT,
	active		TINYINT NOT NULL DEFAULT '0',
	last_update	BIGINT NOT NULL,
	updated_by	VARCHAR(32) NOT NULL,
	description	TEXT,
	PRIMARY KEY(policy_id)
) Engine=InnoDB DEFAULT CHARSET=utf8;