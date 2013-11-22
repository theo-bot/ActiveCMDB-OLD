package ActiveCMDB::Common::Menu;

=head1 MODULE - ActiveCMDB::Common::Menu
    ___________________________________________________________________________

=head1 VERSION

    Version 1.0

=head1 COPYRIGHT

    Copyright (C) 2011-2015 Theo Bot

    http://www.activecmdb.org


=head1 DESCRIPTION

    Common menu functions

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

use Exporter;
use ActiveCMDB::Object::menuItem;
use ActiveCMDB::Model::CMDBv1;


our @ISA = ('Exporter');
our @EXPORT = qw(
	CreateMenuItem
	GetMenuItems
);

sub CreateMenuItem
{
	my($item) = @_;
	my $data = undef;
	
	my $menuItem = ActiveCMDB::Object::menuItem->new(label => $item);
	if ( $menuItem->get_data() )
	{
		if ( defined($menuItem->icon) && $menuItem->icon )
		{
			$data->{label} = sprintf("<img src=\"/static/images/menu/%s\"> %s", 
						$menuItem->icon,  
						$menuItem->label
					);
		} else {
			$data->{label} = $menuItem->label
		}
		
		if ( defined($menuItem->url) && $menuItem->url ) {
			$data->{url} = $menuItem->url;
		}
		
		if ( defined($menuItem->children) && scalar split(/\,/, $menuItem->children) )
		{
			foreach my $child (split(/\,/, $menuItem->children))
			{
				push(@{$data->{children}}, CreateMenuItem($child));
			}
		}
		
	} else {
		Logger->warn("Unable to create menu for $item");
	}
	
	return $data;
}

sub GetMenuItems
{
	my %items = ();
	my $schema = ActiveCMDB::Model::CMDBv1->instance();
	my $res = $schema->resultset("CmdbMenu")->search(
		undef,
		{
			order_by => 'id',
			columns  => qw/label/
		}
	);
	if ( defined($res) )
	{
		while ( my $row = $res->next )
		{
			my $i = ActiveCMDB::Object::menuItem->new(label => $row->label);
			$i->get_data();
			$items{ $i->label } = $i;
		}
	}
	
	return %items;
}