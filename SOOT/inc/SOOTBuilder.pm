package SOOTBuilder;
use strict;
use warnings;
use File::Spec;
use Carp;
use Config;

use inc::latest 'Module::Build';
use inc::latest 'ExtUtils::Typemap';
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

sub ACTION_code {
  my $self = shift;
  $self->depends_on('build_soot');

  $self->SUPER::ACTION_code(@_);
}

sub ACTION_build_soot {
  my $self = shift;
  $self->depends_on('gen_constants');
  $self->depends_on('gen_xsp_include');
  $self->depends_on('merge_typemaps');

  #my $p = $self->{properties};
  #local $p->{extra_compiler_flags} = [
  #  @{$self->extra_compiler_flags},
  #  '-Itools/puic',
  #  '-Itools/puic/perl',
  #];
  my @objects;
  my $files = $self->_find_file_by_type('cc', 'src');
  foreach my $file (keys %$files) {
    push(@objects, $self->compile_c($file));
  }

  #my $script_dir = File::Spec->catdir($self->blib, 'script');
  #File::Path::mkpath( $script_dir );

  #my $puic = File::Spec->catfile($script_dir, '/puic4');

  #unless($self->up_to_date(\@objects, [$puic])) {
  #  $self->_cbuilder->link_executable(
  #    exe_file => $puic,
  #    objects => \@objects,
  #    extra_linker_flags => $p->{extra_linker_flags},
  #  );
  #}

  $self->depends_on('config_data');
  $self->depends_on('gen_examples');
}

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

our @Typemaps = qw(
  perlobject.map
  custom.map
  rootclasses.map
);

sub ACTION_merge_typemaps {
  my $self = shift;
  $self->depends_on('gen_xsp_include');

  my $typemap = 'typemap';
  if (-f $typemap) { # lazy!
    my $latest = 1e9;
    foreach my $file (@Typemaps) {
      $latest = -s _ if -s $file < $latest;
    }
    if (-s $typemap > $latest) {
      return 1;
    }
    unlink $typemap;
  }

  print "Merging custom typemaps...\n";
  my $outmap = ExtUtils::Typemap->new(file => 'typemap');
  foreach my $typemap_file (@Typemaps) {
    print "... merging $typemap_file\n";
    $outmap->merge(typemap => ExtUtils::Typemap->new(file => $typemap_file));
  }
  print "Done merging typemaps.\n";
  $outmap->write();
  return 1;
}

