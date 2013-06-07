package ActiveCMDB::Common;

use Exporter;
@ISA = ('Exporter');

@EXPORT = qw(
				subst_envvar reftype
			);

sub subst_envvar {
	$data = shift;
	
	foreach $var (keys %ENV) {
		$data =~ s/\$$var/$ENV{$var}/;
	}
	
	return $data;
}
sub reftype
{
   return ref $_[0] ? ref $_[0] : "SCALAR";
}