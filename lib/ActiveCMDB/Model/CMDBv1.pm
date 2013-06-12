package ActiveCMDB::Model::CMDBv1;

=begin nd

    Script: ActiveCMDB::Model::CMDBv1.pm
    ___________________________________________________________________________

    Version 1.0

    Copyright (C) 2011-2015 Theo Bot

    http://www.activecmdb.org


    Topic: Purpose

    DBIC Model for connecting to datawarehouse (MySQL)

    About: License

    This program is free software; you can redistribute it and/or
    modify it under the terms of the GNU General Public License
    as published by the Free Software Foundation; either version 2
    of the License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    Topic: Release information

    $Rev$

	
=cut

#########################################################################
# Initialize  modules
use strict;
use base 'Catalyst::Model::DBIC::Schema';
use MooseX::Singleton;
use ActiveCMDB::ConfigFactory;
use ActiveCMDB::Common::Crypto;
use Data::Dumper;
use Logger;

my $config = ActiveCMDB::ConfigFactory->instance();
$config->load('cmdb');
my $dbinfo = $config->section('cmdb::database');
my $global = $config->section('cmdb::default');
if ( $dbinfo->{pwencr} == 1 ) {
	$dbinfo->{dbpass} = cmdb_decrypt($global->{keyname}, $dbinfo->{dbpass});
}

__PACKAGE__->config(
    schema_class => 'ActiveCMDB::Schema',
    
    connect_info => {
        dsn      => 'dbi:' . $dbinfo->{dbtype} . ':database=' . $dbinfo->{dbname} . ':host=%s',
        user     => $dbinfo->{dbuser},
        password => $dbinfo->{dbpass},
        dbhost   => $dbinfo->{dbhost}
    }
);

1;
