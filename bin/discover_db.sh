

#    Script: discover_db.sh
#    ___________________________________________________________________________
#
#    Version 1.0
#
#    Copyright (C) 2011-2015 Theo Bot
#
#    http://www.activecmdb.org
#
#
#    Topic: Purpose
#
#    Discover schema and and create schema files. This will destroy 
#    customizations
#
#    About: License
#
#    This program is free software; you can redistribute it and/or
#    modify it under the terms of the GNU General Public License
#    as published by the Free Software Foundation; either version 2
#    of the License, or (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    Topic: Release information
#
#    $Rev$
#	

cd $CMDB_HOME

./script/activecmdb_create.pl model CMDBv1 DBIC::Schema ActiveCMDB::Schema create=static overwrite_modifications=1 dbi:mysql:ActiveCMDB activecmdb toegang
