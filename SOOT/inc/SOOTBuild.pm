package inc::SOOTBuild;
use strict;
use warnings;
use File::Spec;
use ExtUtils::MakeMaker;
use Config;

# simply a container for multiple Makefile.PL's configuration

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


our $CC = 'g++';

our @Libs = qw();

our @Typemaps = qw(
  perlobject.map
  typemap
  rootclasses.map
);

our $ROOTConfig = 'root-config';
if (!can_run($ROOTConfig)) {
  if (defined $ENV{ROOTSYS}) {
    $ROOTConfig = File::Spec->catfile($ENV{ROOTSYS}, 'bin', 'root-config');
  }
  if (!can_run($ROOTConfig)) {
    die "Cannot find and run the 'root-config' tool. Do you have ROOT installed and set up correctly?\n";
  }
}

sub GetMMArgs {
  my $subdir = shift;

  my @typemaps;
  my @inc;
  if ($subdir eq '.') {
    @inc = qw(. src);
    @typemaps = @Typemaps;
  }
  else {
    @inc = qw(. ..);
    @typemaps = map {File::Spec->catdir(File::Spec->updir, $_)} @Typemaps;
  }
  if (defined $ENV{ROOTSYS}) {
    push @inc, File::Spec->catdir($ENV{ROOTSYS}, 'include'),
               File::Spec->catdir($ENV{ROOTSYS}, 'include', 'root');
  }
  
  my @libs = @Libs;
  push @libs, striprun($ROOTConfig, '--libs');

  use Config;
  my @mmargs = (
      LDDLFLAGS => $Config::Config{lddlflags} . ' ' . striprun($ROOTConfig, '--ldflags'),
      LIBS          => join(' ', @libs), # e.g., '-lm'
      DEFINE        => '', # e.g., '-DHAVE_SOMETHING'
      #INC          => '-I. -Isrc', # e.g., '-I. -I/usr/include/other'
      OBJECT        => '$(O_FILES)', # link all the C files too
      'XSOPT'       => '-C++ -hiertype',
      'TYPEMAPS'    => \@typemaps,
      'CC'          => $CC,
      'LD'          => '$(CC)',
      'INC'         => striprun($ROOTConfig, '--cflags') . ' ' . join(' ', map {"-I$_"} @inc),
  );
  return @mmargs;
}

package ExtUtils::MM;

# for including the object files from src/ into the linking step
sub init_dirscan {
  my $self = shift;
  my @ret = $self->SUPER::init_dirscan(@_);
  opendir my $dh, 'src' or return @ret;
  my @o;
  while (defined(my $file = readdir($dh))) {
    if ($file =~ /\.cc$/i) {
      $file =~ s/\.cc$/$self->{OBJ_EXT}/i;
      push @o, File::Spec->catfile('src', $file);
    }
  }
  push @{$self->{O_FILES}}, @o;
  return @ret;
}

package inc::SOOTBuild;
1;

