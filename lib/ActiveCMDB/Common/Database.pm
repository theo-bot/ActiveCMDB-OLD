package ActiveCMDB::Common::Database;

use Data::Dumper;

sub connect_info {
	my($self) = @_;
	
	my $dbinfo = $self->{config}->section('cmdb::database');
	my $connect_info = {
		dsn => 'dbi:' . $dbinfo->{dbtype} . ':' . $dbinfo->{dbname},
		user => $dbinfo->{dbuser},
		password => $dbinfo->{dbpass},
	};
	
	return $connect_info;
}

1;