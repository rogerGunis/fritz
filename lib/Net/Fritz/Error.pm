package Net::Fritz::Error;
use strict;
use warnings;

# TODO: use a global configuration option to make every call to
#       Net::Fritz::Error->new an immediately fatal error?

use Moo;

=head1 NAME

Net::Fritz::Error - wraps any error from the L<Net::Fritz> modules

=head1 SYNOPSIS

    $root_device = Net::Fritz::Box->new->discover;
    $root_device->errorcheck;

or

    $root_device = Net::Fritz::Box->new->discover;
    if ($root_device->error) {
        die "error: " . $root_device->error;
    }

=head1 DESCRIPTION

Whenever any of the L<Net::Fritz> modules detects an error, it returns
an L<Net::Fritz::Error> object.  All valid (non-error) objects also
implement C<error> and C<errorcheck> via the role
L<Net::Fritz::IsNoError>, so calling both methods always works for any
L<Net::Fritz> object.

If you want your code to just C<die()> on any error, call
C<$obj->errorcheck> on every returned object (see first example
above).

If you just want to check for an error and handle it by yourself, call
C<$obj-E<gt>error>.  All non-errors will return C<0> (see second
example above).

You don't have to check for errors at all, but then you might run into
problems when you want to invoke methods on an L<Net::Fritz::Error>
object that don't exist (because you expected to get eg. an
L<Net::Fritz::Service> object instead).

=head1 ATTRIBUTES (read-only)

=head2 error

Contains the error message as a string.  Don't set this to anything
resembling false or you will trick your tests.

=cut

has error => ( is => 'ro', default => 'generic error' );

=head1 METHODS

=head2 new

Creates a new L<Net::Fritz::Error> object.  You propably don't have to
call this method, it's mostly used internally.  Expects parameters in
C<key =E<gt> value> form with the following keys:

=over

=item I<error>

set the error message

=back

With only one parameter (in fact: any odd value of parameters), the
first parameter is automatically mapped to I<error>.

=cut

sub BUILDARGS {
    my ( $class, @args ) = @_;
    
    unshift @args, "error" if @args % 2 == 1;
    
    return { @args };
};

=head2 errorcheck
    
Immediately C<die()>, printing the error text.

=cut

sub errorcheck {
    my $self = shift;
    die "Net::Fritz::Error: " . $self->error. "\n";
}

=head2 dump

Returns some preformatted information about the object.  Useful for
debugging purposes, printing or logging.

=cut

sub dump {
    my $self = shift;

    return "Net::Fritz::Error: " . $self->error . "\n";
}

=head1 COPYRIGHT

Copyright (C) 2015 by  Christian Garbs <mitch@cgarbs.de>

=head1 LICENSE

Licensed under GNU GPL v2 or later, see
L<http://www.gnu.org/licenses/gpl-2.0-standalone.html>

=head1 AUTHOR

Christian Garbs <mitch@cgarbs.de>

=head1 SEE ALSO

See L<Net::Fritz> for general information about this package,
especially L<Net::Fritz/INTERFACE> for links to the other classes.

=cut

1;
