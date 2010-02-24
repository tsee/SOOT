package TObject;
use strict;
use warnings;
use vars qw/$AUTOLOAD/;

use overload 
  '&{}' => sub {
    my $obj = shift;
    my $class = ref($obj);
    return sub {
      if (@_ == 1 and ref($_[0]) and ref($_[0])->isa($class)) {
        return SOOT::CallAssignmentOperator($class, $obj, $_[0]);
      }
      else {
        Carp::croak("Trying to call assignment operator without an object to copy");
      }
    };
  };

sub AUTOLOAD {
  $AUTOLOAD =~ s/::([^:]+)$//;
  my $method = $1;
  return SOOT::CallMethod($AUTOLOAD, $method, \@_);
}

1;
