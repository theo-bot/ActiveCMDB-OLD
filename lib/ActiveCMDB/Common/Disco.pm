package ActiveCMDB::Common::Disco;

use Exporter;
use Logger;
use ActiveCMDB::Common::Constants;
use ActiveCMDB::Object::Disco;
use ActiveCMDB::Model::CMDBv1;
use Try::Tiny;
use strict;
use Data::Dumper;

our @ISA = ('Exporter');

our @EXPORT = qw(
	cmdb_edit_disco_schedule
	cmdb_add_disco_schedule
);

sub cmdb_edit_disco_schedule
{
	my($args) = @_;
	if ( defined($args->{name}) )
	{
		my $disco = cmdb_get_disco_by_name($args->{name});
		if ( defined($disco) )
		{
			# Test block values
			if ( cmdb_test_blocks($args) )
			{			
				foreach my $attr (keys %{$args})
				{
					if ( defined($args->{$attr}) ) {
						if ($attr =~ /^block\d$/ ) {
							$args->{$attr} = cmdb_convert_block($args->{$attr});
						}
						$disco->$attr($args->{$attr});
					}
				}
				return $disco->save();
			} else {
				Logger->warn("One of the block values was in correct (hh:mm-hh:mm)");
			}
		}
	}
}

sub cmdb_add_disco_schedule
{
	my($args) = @_;
	if ( defined($args->{name}) )
	{
		my $disco = cmdb_get_disco_by_name($args->{name});
		if ( !defined($disco) )
		{
			$disco = ActiveCMDB::Object::Disco->new();
			# Test block values
			if ( cmdb_test_blocks($args) )
			{			
				foreach my $attr (keys %{$args})
				{
					if ( defined($args->{$attr}) ) {
						if ($attr =~ /^block\d$/ ) {
							$args->{$attr} = cmdb_convert_block($args->{$attr});
						}
						Logger->info("Setting attribute $attr");
						$disco->$attr($args->{$attr});
					}
				}
				return $disco->save();
			} else {
				Logger->warn("One of the block values was in correct (hh:mm-hh:mm)");
			}
		} else {
			Logger->warn("Cannot add discovery scheme with dupplicate name.");
		}
	}
}

sub cmdb_get_disco_by_name
{
	my($name) = @_;
	
	my $disco = undef;
	my $schema = ActiveCMDB::Model::CMDBv1->instance();
	my $row = $schema->resultset('DiscoScheme')->find({ name => $name }, { columns => qw/scheme_id/ });
	if ( defined($row) )
	{
		$disco = ActiveCMDB::Object::Disco->new(scheme_id => $row->scheme_id);
		$disco->get_data();
	} else {
		Logger->warn( "Schedule name not found" );
	}
	
	return $disco;
}

sub cmdb_test_blocks
{
	my($args) = @_;
	my $result = true;
	
	foreach my $block (qw/block1 block2/)
	{
		if ( defined($args->{$block}) )
		{
			if ( $args->{$block} =~ /^(\d\d):(\d\d)-(\d\d):(\d\d)$/ )
			{
				my $t1 = 60 * $1 + $2;
				my $t2 = 60 * $3 + $4;
				if ( $t1 < 0 || $t1 > 1440 || $t2 < 0 || $t2 > 1440 || $t2 < $t1 ) {
					$result = false;
				}
			} else {
				$result = false;
			}
		}
	}
	
	return $result;
}

sub cmdb_convert_block
{
	my($block) = @_;
	my $moment = '';
	
	if ( $block =~ /^(\d\d):(\d\d)-(\d\d):(\d\d)$/ ) {
		$moment = sprintf("%d;%d", 60 * $1 + $2, 60 * $3 + $4 );
	}
	
	return $moment;
}