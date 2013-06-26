package MooseX::MethodPrivate;

use Moose;
use Moose::Exporter;
use Carp qw/croak/;

our $VERSION = '0.1.1';

Moose::Exporter->setup_import_methods(
    with_caller => [qw( private protected )], );

sub private {
    my $caller = shift;
    my $name = shift;
    my $real_body = shift;

    my $body = sub {
        croak "The $caller\::$name method is private"
            unless ( scalar caller() ) eq $caller;

        goto &{$real_body};
    };

    $caller->meta->add_method( $name, $body );
}

sub protected {
    my $caller = shift;
    my $name = shift;
    my $real_body = shift;

    my $body = sub {
        my $new_caller = caller();
        croak "The $caller\::$name method is protected"
            unless ( ( scalar caller() ) eq $caller
            || $new_caller->isa($caller) );

        goto &{$real_body};
    };

    $caller->meta->add_method( $name, $body );
}

1;

__END__

=head1 NAME

MooseX::MethodPrivate - Declare methods private or protected

=head1 SYNOPSIS

package Foo;
use MooseX::MethodPrivate;

private 'foo' => sub {
...
}

protected 'bar' => sub {
...
}

...

my $foo = Foo->new;
$foo->foo; # die, can't call foo because it's a private method
$foo->bar; # die, can't call bar because it's a protected method

package Bar;
use MooseX::MethodPrivate;
extends qw/Foo/;

sub baz {
my $self = shift;
$self->foo; # die, can't call foo because it's a private method
$self->bar; # ok, can call this method because we extends Foo and
# it's a protected method
}

=head1 DESCRIPTION

MooseX::MethodPrivate add two new keyword for methods declaration:

=over 2

=item B<private>

=item B<protected>

=back

=head2 METHODS

=over 4

=item B<private>

A private method is visible only in the class.

=item B<protected>

A protected method is visible in the class and any subclasses.

=back

=head1 AUTHOR

franck cuny E<lt>franck.cuny {at} rtgi.frE<gt>

=head1 SEE ALSO

Idea stolen from L<Moose::Cookbook::Meta::Recipe6>.

=head1 LICENSE

Copyright (c) 2009, RTGI
All rights reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.