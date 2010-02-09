package inc::SOOTBuild;
use strict;
use warnings;
use File::Spec;
use ExtUtils::MakeMaker;

# simply a container for multiple Makefile.PL's configuration

our $CC = 'g++';

our @Libs = qw(
);

our @Typemaps = qw(
  perlobject.map
  typemap
);

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
  my @mmargs = (
      LIBS              => \@Libs, # e.g., '-lm'
      DEFINE            => '', # e.g., '-DHAVE_SOMETHING'
      #INC               => '-I. -Isrc', # e.g., '-I. -I/usr/include/other'
      OBJECT            => '$(O_FILES)', # link all the C files too
      'XSOPT'             => '-C++ -hiertype',
      'TYPEMAPS'          => \@typemaps,
      'CC'                => $CC,
      'LD'                => '$(CC)',
      'INC' => join(' ', map {"-I$_"} @inc),
  );
  return @mmargs;
}

package ExtUtils::MM;

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

