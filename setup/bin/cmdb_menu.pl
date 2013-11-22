#!/usr/bin/env perl

use v5.16.0;
use strict;
use Getopt::Long;
use Switch;
use ActiveCMDB::Object::menuItem;
use ActiveCMDB::Common::Menu;
use Data::Dumper;

my($label,$icon,$active,$url, $parent, $before, $after,$export);
my $action = "";
my %attr = ();

GetOptions(
	"label=s"		=> \$attr{label},
	"delete"	=> sub { $action = "delete"; },
	"edit"		=> sub { $action = "edit";   },
	"add"		=> sub { $action = "add"; },
	"export"	=> sub { $action = "export"; },
	"icon=s"	=> \$attr{icon},
	"active=i"	=> \$attr{active},
	"url=s"		=> \$attr{url},
	"parent=s"	=> \$attr{parent},
	"after=s"	=> \$attr{pos}->{after},
	"before=s"	=> \$attr{pos}->{before}
);

if ( $attr{pos}->{after} && $attr{pos}->{before} ) {
	print "options --after and --before are mutually exclusive\n";
	exit;
}
if ( !defined($attr{label}) )
{
	print "Attribute label is required for add/edit/delete options\n"
}

switch ( $action )
{
	case "delete"	{ delete_menu_item(%attr); }
	case "edit"		{ edit_menu_item(%attr); }
	case "add"		{ add_menu_item(%attr); }
}

exit;

sub add_menu_item
{
	my(%attr) = @_;
	my $item = ActiveCMDB::Object::menuItem->new(label => $attr{label});
	if ( !$item->get_data() )
	{
		foreach my $attr (qw/icon url active/ ) { $item->$attr($attr{$attr}); }

	
		if ( defined($attr{parent}) && $attr{parent} )
		{
			my $parent = ActiveCMDB::Object::menuItem->new(label => $attr{parent});
			if ( $parent->get_data() )
			{
				my $children = $parent->children;
				
				if ( defined($attr{pos}->{before}) )
				{
					if ( $children =~ /$attr{pos}->{before}/ ) {
						my $replace = $item->label . ',' . $attr{pos}->{before};
						my $search  = $attr{pos}->{before};
						$children =~ s/$search/$replace/;
					} else {
						if ( $children ) { $children .= ','; }
						$children .=  $item->label;
					}
				} elsif ( defined($attr{pos}->{after}) ) {
						if ( $children =~ /$attr{pos}->{after}/ ) {
							$children =~ s/$attr{pos}->{after}/$attr{pos}->{after} . ',' . $item->label/;
						} else {
							if ( $children ) { $children .= ','; }
							$children .= $item->label;
						}
				} else {
					if ( $children ) { $children .= ','; }
					$children .= $item->label;
				}
				$parent->children($children);
				$parent->save();
				$item->save();
			} else {
				print "Unable to locate parent data\n";
				exit;
			}
		}
	} else {
		print "Cannot add duplicate menu item\n";
		exit;
	}
}

sub edit_menu_item
{
	my(%attr) = @_;
	my $item = ActiveCMDB::Object::menuItem->new(label => $attr{label});
	if ( $item->get_data() )
	{
		foreach my $attr (qw/url active icon/)
		{
			if ( defined($attr{$attr}) && $attr{$attr} )
			{
				$item->$attr( $attr{$attr} );
			}
		}
		
		$item->save();
	}
}
