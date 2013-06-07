#!/usr/bin/env perl

use v5.16.0;
use ActiveCMDB::Common::Crypto;
use Getopt::Long;

my $keyname = undef;

GetOptions(
			'name=s'	=> \$keyname
		  );


if ( defined($keyname) && length($keyname) > 4 ) 
{		  
	cmdb_genkey($keyname);
} else {
	print "Invalid keyname.\n";
}

exit;