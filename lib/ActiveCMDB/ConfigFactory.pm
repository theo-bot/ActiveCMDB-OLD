package ActiveCMDB::ConfigFactory;

=head1 Module - ActiveCMDB::ConfigFactory
    ___________________________________________________________________________

=head1 Version 
	1.0

=head1 Copyright
    Copyright (C) 2011-2015 Theo Bot

    http://www.activecmdb.org


=head1 Description

    Configuration System Library

=head1 License

    This program is free software; you can redistribute it and/or
    modify it under the terms of the GNU General Public License
    as published by the Free Software Foundation; either version 2
    of the License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.


=cut

use base qw( Class::Singleton );
use Config::JFDI;
use File::stat;
use Data::Dumper;

=head1 Methods

=head2 instance

Create an instance. Since it is a singleton object, all processes
using this object get the same data.

=cut

sub _new_instance {
	my $class = shift;
	
	my $self = bless { }, $class;
	
	return $self;
}

=head2 load

Import a configuration file from the $ENV{CMDB_HOME}/conf directory.

=cut

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
			print "Failed to open configfile, $!\n";
		}
	}
}

=head2 section

Returns a part of the configuration. 

 Argurments:
 $self		- Reference to object instance
 $section	- Double colon seprated list of the config
 
 Example:

 $data = $config->section("cmdb::default::version");
 
 cmdb is the file which is loaded (cmdb.yml).

=cut

sub section {
	my($self, $section) = @_;
	my @parts = split(/\:\:/, $section);
	
	my $cfg = $self->{shift @parts}->{config};
	foreach my $p (@parts) {
		$cfg = $cfg->{$p};
	}
	
	return $cfg;
}

=head2 config

Return the configuration

=cut

sub config {
	my ($self) = @_;
	
	return $self->{config};
}

1;