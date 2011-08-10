package # hide from PAUSE
  TClass;
use strict;
use warnings;

# TODO document

sub soot_method_complete {
  my $self = shift;
  my $stub = shift;
  my $exact = shift;
  my $candidates = $self->_soot_method_complete_internal(defined($stub) ? $stub : "", 0, $exact ? 1 : 0);

  my @rv;
  foreach my $cand (@$candidates) {
    next unless $cand =~ s/^(\S+)\s+((?:\w+::)+)(\w+)\(//;
    my ($ret_type, $class, $methname) = ($1, $2, $3);
    $class =~ s/::$//;
    chop($cand); # closing paren

    my $struct = {
      class => $class, method => $methname, return_type => $ret_type,
      parameters => [],
    };
    push @rv, $struct;

    my @ps = split /,/, $cand;
    my $params = $struct->{parameters};
    foreach my $p (@ps) {
      my ($t, $n) = split /\s+/, $p, 2;
      ($n, my $def) = split /=/, $n, 2;
      push @$params, [$t, $n, defined($def) ? ($def) : () ];
    }
  }
  return @rv;
}

sub soot_method_complete_proto_str {
  my $self = shift;
  my $stub = shift;
  my $exact = shift;
  my $candidates = $self->_soot_method_complete_internal(defined($stub) ? $stub : "", 0, $exact ? 1 : 0);
  return @$candidates;
}

sub soot_method_complete_name {
  my $self = shift;
  my $stub = shift;
  my $exact = shift;
  my $candidates = $self->_soot_method_complete_internal(defined($stub) ? $stub : "", 1, $exact ? 1 : 0);
  return @$candidates;
}

1;
