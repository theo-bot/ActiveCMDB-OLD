package ActiveCMDB::Common::Import;
=head1 MODULE - ActiveCMDB::Common::Import
    ___________________________________________________________________________

=head1 VERSION

    Version 1.0

=head1 COPYRIGHT

    Copyright (C) 2011-2015 Theo Bot

    http://www.activecmdb.org


=head1 DESCRIPTION

    Common import functions

=head1 LICENSE

    This program is free software; you can redistribute it and/or
    modify it under the terms of the GNU General Public License
    as published by the Free Software Foundation; either version 2
    of the License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

=cut

=head1 IMPORTS
 use Exporter;
 use Logger;
 use ActiveCMDB::Model::Cloud;
 use Try::Tiny;
 use strict;
 use Data::Dumper;
=cut


use Exporter;
use Try::Tiny;
use Logger;
use ActiveCMDB::Common::Constants;
use ActiveCMDB::Common::Security;
use ActiveCMDB::Object::Import;
use ActiveCMDB::Model::Cloud;
use ActiveCMDB::Common::Conversion;
use strict;
use Data::Dumper;
use Module::Load;
use JSON::XS;
use File::Slurp;

our @ISA = ('Exporter');

our @EXPORT = qw(
	cmdb_get_imports
	cmdb_import_start
	cmdb_import_types
);

no strict 'refs';

sub cmdb_get_imports
{
	my($order, $start, $rows, $query) = @_;
	my %objects = ();
	my @objects = ();
	my $numerical = true;
	
	my $schema = ActiveCMDB::Model::Cloud->new();
	
	if ( !defined($query) ) {
		$query = 'dt:cmdbImport';
	}
	
	my $res = $schema->client->search(index => 'cmdbImport', sort => $order, q => $query, wt => 'json' );
	
	foreach my $doc (@{$res->{response}->{docs}})
	{
		push(@objects, $doc->{fields});
	}
	
	return @objects;
}

sub cmdb_import_start
{
	my($data) = @_;
	my $jobresult = 1;
	
	if ( defined($data->{id}) )
	{
		Logger->info("Starting import job " . $data->{id});
		my $import = ActiveCMDB::Object::Import->new(id => $data->{id});
		my $res = $import->get_data();
		
		if ( defined($res) && $res )
		{
			Logger->info("Object loaded from cloud");
			$import->progress(0);
			Logger->info("Importing file configuration for object type " . $import->object_type);
			my $coder = JSON::XS->new->ascii->pretty->allow_nonref;
			my $config_file = sprintf("%s/conf/import/%s.map", $ENV{CMDB_HOME}, $import->object_type());
			my $config_data = read_file($config_file);
			my $config = $coder->decode($config_data);
		
			my $class = undef;
			my %loaded = ();
			
			try {
				$class = $config->{ObjectClass};
				Logger->debug("Loading class $class");
		
				load $class;
				foreach my $f (sort {$a <=> $b} keys %{$config->{Fields}})
				{
					$class = $config->{Fields}->{$f}->{class};
					next if $loaded{$class};
					Logger->debug("Loading class $class");
					load $class;
					$loaded{$class} = true;
				}
				Logger->debug(Dumper($config->{Library}));
				foreach my $class (@{$config->{Library}})
				{
					next if $loaded{$class};
					Logger->debug("Loading class $class");
					my $stm = sprintf("use %s;", $class);
					eval $stm;
					$loaded{$class} = true;
				}
				%loaded = undef;
			} catch {
				Logger->error("Failed to load class/moudule $class\n" . $_);
				return 0;
			};
		
			my $lc = 0;
			foreach ( $import->all_lines() )
			{
				
				next if ( $_->status == 1 );
				Logger->info("Processing line " . $_->ln() );
				my @data = split(/\,/, $_->data );
				my $result = true;
				my $reason = "";
				my $import_object = $config->{ObjectClass}->new();
				foreach my $f (sort {$a <=> $b} keys %{$config->{Fields}})
				{
					$reason = "";
					Logger->debug("Testing field $f " . $config->{Fields}->{$f}->{map} );
					my $args  = $config->{Fields}->{$f};
					my $class = $args->{class};
					my $object = undef;
					if ( defined($data[$f]) )
					{	
						$args->{value} = $data[$f];
						$object = $class->new($args);
						($result, $reason) = $object->check();
						#if ( !$result )
						#{
						#	Logger->warn("Check method failed");
						#}
						if ( $result && defined($args->{verify}) ) {
							# We have a correct value but is it already in the database?
							my $coderef = $args->{verify};
							if ( defined(&$coderef) )
							{
								Logger->debug("Verify value via $coderef");
								$result = &$coderef($object->value);
								if ( !$result ) {
									Logger->warn("Referenced value missing");
								} else {
									Logger->info("Referenced value present");
									if ( $result ne $object->value ) {
										$object->value($result);
									}
								}
							} else {
								Logger->error("Syntax error in map file, invalid verification routine $coderef");
							}
						}
					} elsif ( defined($args->{required}) &&  $args->{required} == 1 ) {
						if ( defined($args->{default}) )
						{
							$result = true;
							$data[$f] = $args->{default};
							Logger->debug("Assigning default value");	
						} else {
							$reason = "Required data is missing for field $f";
							$result = false;
						}
					} elsif ( !defined($args->{required}) || (defined($args->{required}) &&  $args->{required} == 1) ) {
						if ( defined($args->{default}) ) {
							$result = true;
							$data[$f] = $args->{default};
							Logger->debug("Assigning default value");
						}
					}
					if ( $result ) {
						if ( defined($object) && defined($object->value) )
						{
							my $method = $args->{map};
							Logger->debug("Assigning " . $object->value . " to $method ");
							$import_object->$method($object->value);
						} else {
							Logger->info("No value to assign");
						}
					} else {
						Logger->warn("Pre-checks dit not comply for " . $args->{map});
					}
					if ( $reason ) { Logger->debug($reason); }			
				}
				if ( ! $result ) { 
					Logger->warn("Line " . $_->ln() . " failed to import");
					
					$_->status(2);
					$jobresult = $result; 
				} else {
					
					#
					# Do some post processing on the object of requested
					#
					if ( defined($config->{PostProcess}) )
					{
						my $pp = $config->{PostProcess};
						if ( $import_object->can($pp) ) {
							$import_object->$pp();
						} else {
							Logger->error("Syntax error in map file, undefined object method $pp");
						}
						
					}
					
					#
					# Update the status of the line object
					#
					$_->status(1);
				
					#
					# Save the import object
					#
					$import_object->save();
				}
				
				#
				# Save the line object
				#
				$_->save();
			}
		
			if ( $jobresult )
			{
				# Job completed successfully
				
				#
				# Delete the import object
				#
				$import->delete();
			} else {
				#
				# Flag the job has failed
				#
				$import->status(2);
				
				#
				# Save the data
				#
				$import->save();
			}
		} else {
			Logger->warn("Import not found");
			
		}
	
	} else {
		Logger->warn("Invalidig arguments.");
			Logger->debug(Dumper($data));
			$jobresult = 0;
	}
	return $jobresult;
}

sub cmdb_import_types
{
	my($c) = @_;
	my %all = cmdb_name_set('importObject');
	my %types = ();
	foreach my $key (keys %all)
	{
		my $role = lc($key) . 'Admin';
		if ( cmdb_check_role($c, $role) )
		{
			$types{$key} = $all{$key};
		}
	}
	
	return %types
}