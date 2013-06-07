cd $CMDB_HOME

./script/activecmdb_create.pl model CMDBv1 DBIC::Schema ActiveCMDB::Schema create=static overwrite_modifications=1 dbi:mysql:ActiveCMDB activecmdb toegang
