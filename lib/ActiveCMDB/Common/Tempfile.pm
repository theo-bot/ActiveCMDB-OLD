package ActiveCMDB::Common::Tempfile;
=head1 MODULE - ActiveCMDB::Common::Tempfile
    ___________________________________________________________________________

=head1 VERSION

    Version 1.0

=head1 COPYRIGHT

    Copyright (C) 2011-2015 Theo Bot

    http://www.activecmdb.org


=head1 DESCRIPTION

    Manage temporary files

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

 use Moose;
 use File::Basename;
 use IO::File;
 use Logger;
=cut

use Moose;
use MooseX::MethodPrivate;
use File::Basename;
use IO::File;
use Logger;

=head1 ATTRIBUTES

=head2 filename

String containing full pathname
=cut
has filename	=> ( is => 'rw', isa => 'Str' );

=head2 template

String containing a format for filenames. During file creation
2 or more consecutive X's will be replaced by random characters
=cut
has template	=> ( is => 'ro', isa => 'Str' );

=head2 path

String containing the folder where the tempfile will be created
=cut
has path		=> ( is => 'ro', isa => 'Str' );

=head2 suffix

String containing the suffix for the file
=cut
has suffix		=> ( is => 'ro', isa => 'Str' );

=head2 fh

FileHandle to opened file
=cut
has fh			=> ( is => 'rw', isa => 'FileHandle' );

my @chars = (
			qw/A B C D E F G H I J K L M N O P Q R S T U V W X Y Z
			   a b c d e f g h i j k l m n o p q r s t u v w x y z
			   0 1 2 3 4 5 6 7 8 9 _
			  /
	);
	

=head1 METHODS

=head2 mkfile

Private method to construct a full pathname for the file

=cut

private 'mkfile' => sub {
	my $self = shift;
	
	my $fn = $self->template;
	if ( $fn =~ /(XX+)/ ) {
		my $size = length($1);
		my $x = $1;
		my $y = "";
		for (my $c=1;$c<=$size;$c++) { $y .= $chars[int(rand( @chars))] }
		$fn =~ s/$x/$y/;
	}
	$fn = $self->path . '/' . $fn;
	if ( defined($self->suffix) ) { $fn .= $self->suffix; }
	$self->filename($fn);
};

=head2 create

Create a ful path name with all required attributes
=cut

sub create
{
	my $self = shift;
	if ( defined($self->template) && defined($self->path) )
	{
		$self->mkfile();
	}
}

=head2 open

Open handle to a file on the disk, using the path and filename attributes

 Arguments
 $self		- Reference to object
 $mode		- <,>, >>
 
 Returns
 $self->fh	- IO::File object

=cut

sub open
{
	my($self, $mode) = @_;
	if ( defined($self->filename) && -d $self->path && -w $self->path && ! -f $self->filename )
	{
		my $fh = undef;
		$fh = IO::File->new($self->filename, $mode);
		$self->fh($fh);
	} else {
		if ( ! -d $self->path ) { Logger->warn("Invalid path"); }
		if ( ! -w $self->path ) { Logger->warn("Cannot write to path"); }
		if ( -f $self->filename ) { Logger->warn("Filename already exists"); }
		if ( ! defined($self->filename) ) { Logger->warn("Filename not build"); }
		
		Logger->warn("Failed to open tmpfile. " . $self->filename);
	}
	
	return $self->fh;
}

sub close
{
	my $self = shift;
	
	$self->fh->close();
}

__PACKAGE__->meta->make_immutable;
1;