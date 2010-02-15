package TArray;
use strict;
use warnings;
use vars qw/$AUTOLOAD/;

sub AUTOLOAD {
  $AUTOLOAD =~ s/::([^:]+)$//;
  my $method = $1;
  SOOT::CallMethod($AUTOLOAD, $method, \@_);
}

sub DESTROY () {}

1;

