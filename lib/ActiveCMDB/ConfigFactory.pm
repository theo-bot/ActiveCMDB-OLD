package ActiveCMDB::ConfigFactory;

use base qw( Class::Singleton );
use Config::JFDI;
use File::stat;
use Data::Dumper;


sub _new_instance {
	my $class = shift;
	
	my $self = bless { }, $class;
	
	return $self;
}

sub load {
	my($self, $name) = @_;
	
	if ( defined($name) ) {
		my $path = $ENV{CMDB_HOME} . '/conf/';
		my $jfdi = undef;
		if ( $jfdi = Config::JFDI->new(name => $name, path => $path) )
		{
			$jfdi->get();
			
			if ( $jfdi->found() )
			{
				my $file = ($jfdi->found())[0];
				my $stat = stat($file);
				if ( ( defined($self->{$name}) && $stat->mtime > $self->{$name}->{ts} ) || !defined($self->{$name}) )
				{
					$self->{$name}->{config} = $jfdi->config;
					$self->{$name}->{path} 	 = $path;
					$self->{$name}->{ts}	 = time();
					$self->{$name}->{file}	 = $file;
				} else {
					#print "CFG0001\n";
				}
			} else {
				print "CFG0002\n";
				print Dumper($jfdi),"\n";
			}
			
		} else {
			print "Failed to open logfile, $!\n";
		}
	}
}

sub section {
	my($self, $section) = @_;
	my @parts = split(/\:\:/, $section);
	
	my $cfg = $self->{shift @parts}->{config};
	foreach my $p (@parts) {
		$cfg = $cfg->{$p};
	}
	
	return $cfg;
}

sub config {
	my ($self) = @_;
	
	return $self->{config};
}

1;