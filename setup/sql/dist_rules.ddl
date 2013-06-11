CREATE TABLE dist_rules (
  rule_id int(11) NOT NULL AUTO_INCREMENT,
  model_id int(11) NOT NULL,
  rule_order int(11) DEFAULT '99',
  rule_name varchar(45) DEFAULT NULL,
  rule_active tinyint(1) DEFAULT '1',
  rule_ep int(11) DEFAULT NULL,
  vendors varchar(1024) DEFAULT NULL,
  types varchar(1024) DEFAULT NULL,
  hostname varchar(1024) DEFAULT NULL,
  PRIMARY KEY (rule_id,model_id),
  KEY fk_dist_rules_1 (model_id),
  KEY fk_dist_rules_2 (rule_ep),
  KEY CMDB0002 (model_id,rule_order),
  CONSTRAINT fk_dist_rules_1 FOREIGN KEY (model_id) REFERENCES dist_model (model_id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_dist_rules_2 FOREIGN KEY (rule_ep) REFERENCES dist_endpoint (ep_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=latin1;