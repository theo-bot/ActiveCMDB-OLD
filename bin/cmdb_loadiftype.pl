#!/usr/bin/env perl

use Logger;
use ActiveCMDB::Common::Conversion;

my $file = sprintf("%s/var/mibs/IANA/ianaiftype-mib", $ENV{CMDB_HOME});
open(FH, "<", $file) or die "Unable to open mib file";
my $in = 0;
while ( <FH> )
{
	if ( /IANAifType ::= TEXTUAL-CONVENTION/ ) { $in++ }
	if ( $in && /\{/ ) { $in++ }
	if ( $in == 2 && /(.+)\((\d+)\)/ ) {
		$n = $1;
		$v = $2;
		$n =~ s/^\s+//;
		cmdb_add_conversion('ifType', $v, $n);
	}
	if ( $in == 2 && /\}/ ) { $in = 0; }
}