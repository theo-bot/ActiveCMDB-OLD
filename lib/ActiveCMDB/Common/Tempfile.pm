package ActiveCMDB::Common::Tempfile;

use Moose;
use File::Basename;
use IO::File;
use Logger;

has filename	=> ( is => 'rw', isa => 'Str' );
has template	=> ( is => 'ro', isa => 'Str' );
has path		=> ( is => 'ro', isa => 'Str' );
has suffix		=> ( is => 'ro', isa => 'Str' );
has fh			=> ( is => 'rw', isa => 'Any' );

my @chars = (
			qw/A B C D E F G H I J K L M N O P Q R S T U V W X Y Z
			   a b c d e f g h i j k l m n o p q r s t u v w x y z
			   0 1 2 3 4 5 6 7 8 9 _
			  /
	);
	

sub create
{
	my $self = shift;
	if ( defined($self->template) && defined($self->path) )
	{
		$self->mkfile();
	}
}

sub mkfile
{
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
}

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