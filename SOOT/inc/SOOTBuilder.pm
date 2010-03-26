package SOOTBuilder;
use strict;
use warnings;
use File::Spec;
use Carp;
use Config;

use base 'Module::Build';

# utilities...
##############
sub striprun {
  my $inc = `@_`;
  chomp $inc;
  return $inc;
}

# check if we can run some command (From Module::Install::Can)
sub can_run {
  my ($cmd) = @_;

  my $_cmd = $cmd;
  return $_cmd if (-x $_cmd or $_cmd = MM->maybe_command($_cmd));

  for my $dir ((split /$Config::Config{path_sep}/, $ENV{PATH}), '.') {
    next if $dir eq '';
    my $abs = File::Spec->catfile($dir, $_[1]);
    return $abs if (-x $abs or $abs = MM->maybe_command($abs));
  }

  return;
}

##################

our @Typemaps = qw(
  perlobject.map
  typemap
  rootclasses.map
);
#    'TYPEMAPS'    => \@typemaps,
#    'CC'          => $CC,

sub ACTION_gen_xsp_include {
  my $self = shift;
  system($^X, '-I.', '-Iinc', File::Spec->catfile('buildtools', 'gen_root_xsp_include.pl')) and die $!;
}

sub ACTION_gen_constants {
  my $self = shift;
  system($^X, '-I.', '-Iinc', File::Spec->catfile('buildtools', 'genconstants.pl')) and die $!;
}

sub ACTION_gen_examples {
  my $self = shift;
  system($^X, '-I.', '-Iinc', File::Spec->catfile('buildtools', 'gen_examples.pl')) and die $!;
}
