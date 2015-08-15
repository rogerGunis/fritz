package Fritz::Data;
use strict;
use warnings;

use Scalar::Util qw(blessed);

use Moo;
use namespace::clean;

with 'Fritz::IsNoError';

has data => ( is => 'ro' );

# prepend 'data => ' when called without hash
# (when called with uneven list)
sub BUILDARGS {
    my ( $class, @args ) = @_;
    
    unshift @args, "data" if @args % 2 == 1;
    
    return { @args };
};

sub get {
    my $self = shift;

    return $self->data;
}

sub dump {
    my $self = shift;

    my $indent = shift;
    $indent = '' unless defined $indent;

    print "${indent}" . blessed( $self ) . ":\n";
    print "${indent}----data----\n";
    print $self->data . "\n";
    print "------------\n";
}

1;
