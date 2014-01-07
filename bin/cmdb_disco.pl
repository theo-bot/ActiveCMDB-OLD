#!/usr/bin/env perl

=begin nd

    Script: cmdb_disco.pl
    ___________________________________________________________________________

    Version 1.0

    Copyright (C) 2011-2015 Theo Bot

    http://www.activecmdb.org


    Topic: Purpose

    Maintain discovery schedules

    About: License

    This program is free software; you can redistribute it and/or
    modify it under the terms of the GNU General Public License
    as published by the Free Software Foundation; either version 2
    of the License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

=cut

use v5.16.0;
use Getopt::Long;
use Switch;
use Pod::Usage;
use ActiveCMDB::Common::Conversion;
use ActiveCMDB::Common::Disco;

my ($action, $active,$block1,$block2, $name);

GetOptions(
	"add"		=> sub { $action = 'add'; },
	"update"	=> sub { $action = 'edit'; },
	"help"		=> sub { $action = 'help'; },
	"name=s"		=> \$name,
	"active=i"	=> \$active,
	"block1=s"	=> \$block1,
	"block2=s"	=> \$block2
) or pod2usage(1);

my $args =  {
				name	=> $name,
				active	=> int($active),
				block1	=> $block1,
				block2	=> $block2
			};

switch ($action)
{
	case "add"		{ cmdb_add_disco_schedule($args) }
	case "edit"		{ cmdb_edit_disco_schedule($args) }
	case "help"		{ pod2usage(-verbose => 99, -sections => [ qw/NAME SYSOPSIS DESCRIPTION COPYRIGHT/ ]) }
	else 			{ pos2usage(1) }
}

exit;

__END__

=head1 NAME

cmdb_disco.pl - Various discovery related functions

=head1 SYNOPSIS

sample [options] [file ...]

 Options:
  --help brief help message
  --add add new discovery schedule
  
=head1 OPTIONS

=over 8

=item B<-help>

Print a brief help message and exits.

=item B<-add>

Add a discovery schedule

=head1 DESCRIPTION

B<This program> will read the given input file(s) and do something
useful with the contents thereof.

=head1 COPYRIGHT

Copyright (C) 2011-2015 Theo Bot

http://www.activecmdb.org

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

=back

=cut