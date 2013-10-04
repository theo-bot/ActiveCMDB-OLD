CREATE  TABLE ActiveCMDB.cmdb_menu (
  id INT NOT NULL AUTO_INCREMENT ,
  label VARCHAR(32) NULL ,
  icon VARCHAR(64) NULL ,
  active TINYINT NOT NULL, 
  children TEXT NULL ,
  url TEXT NULL ,
  PRIMARY KEY (id) ,
  UNIQUE INDEX label_UNIQUE (label ASC) 
);
