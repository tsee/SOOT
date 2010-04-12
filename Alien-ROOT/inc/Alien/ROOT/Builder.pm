package Alien::ROOT::Builder;

use strict;
use warnings;

use base 'Module::Build';
use Alien::ROOT::Builder::Utility qw(aroot_touch aroot_install_arch_auto_dir aroot_install_arch_auto_file);

use Cwd ();
use Carp ();

my $ORIG_DIR = Cwd::cwd();

# use the system version of a module if present; in theory this could lead to
# compatibility problems (if the latest version of one of the dependencies,
# installed in @INC is incompatible with the bundled version of a module)
sub _load_bundled_modules {
  # the load order is important: all dependencies must be loaded
  # before trying to load a module
  require inc::latest;

  inc::latest->import( $_ )
    foreach qw(version
               Locale::Maketext::Simple
               Params::Check
               Module::Load
               Module::Load::Conditional
               IPC::Cmd
               Archive::Extract
               File::Fetch
               Capture::Tiny);
}

sub ACTION_build {
  my $self = shift;
  # try to make "perl Makefile.PL && make test" work
  # but avoid doubly building ROOT when doing
  # "perl Makefile.PL && make && make test"
  unlink 'configured' if -f 'configured';
  $self->SUPER::ACTION_build;
}


sub ACTION_code {
  my $self = shift;

  $self->SUPER::ACTION_code;
  return if not $self->notes( 'build_ROOT' );

  # see comment in ACTION_build for why 'configured' is used
  return if -f 'configured';
  $self->depends_on( 'build_ROOT' );
  aroot_touch( 'configured' );
  $self->add_to_cleanup( 'configured' );
}


sub ACTION_build_ROOT {
  my $self = shift;
  return if not $self->notes( 'build_ROOT' );
  $self->fetch_ROOT;
  $self->extract_ROOT;
  $self->build_ROOT;
}

sub ACTION_install {
  my $self = shift;
  $self->SUPER::ACTION_code;
  return if not $self->notes( 'build_ROOT' );
  $self->install_ROOT;
}

sub ACTION_clean {
  my ($self) = @_;

  my $rc = $self->SUPER::ACTION_clean;
  chdir($self->notes('build_data')->{directory});
  $rc = (system($self->notes('make'), 'clean') == 0) ? 1 : 0;
  chdir($ORIG_DIR);

  return $rc;
}


#ftp://root.cern.ch/root/root_v5.26.00.source.tar.gz
sub fetch_ROOT {
  my $self = shift;

  return if defined $self->notes('build_data')->{archive}
         and -f $self->notes('build_data')->{archive};

  $self->_load_bundled_modules;
  print "Fetching ROOT...\n";
  print "fetching from: ", $self->notes('build_data')->{url}, "\n";

  my $ff = File::Fetch->new( uri => $self->notes('build_data')->{url} );
  my $path = $ff->fetch(to => File::Spec->curdir);
  die 'Unable to fetch archive' unless $path;
  $self->notes('build_data')->{archive} = $path;
}

sub extract_ROOT {
  my $self = shift;

  return if -d $self->notes( 'build_data' )->{data}{directory};
  my $archive = $self->notes( 'build_data' )->{data}{archive};
  if (!$archive) {
    $self->fetch_ROOT;
    $archive = $self->notes( 'build_data' )->{data}{archive};
  }

  print "Extracting wxWidgets...\n";

  $self->_load_bundled_modules;
  $Archive::Extract::PREFER_BIN = 1;
  my $ae = Archive::Extract->new( archive => $archive );

  die 'Error: ', $ae->error unless $ae->extract;

  #$self->patch_ROOT;
}

sub build_ROOT {
  my $self = shift;

  my $prefix = $self->aroot_install_arch_auto_dir('root');
  my @cmd = (
    qw(sh configure),
    '--prefix', $prefix,
    '--etcdir', File::Spec->catfile($prefix, 'etc'),
    '--enable-explicitlink', # needed for SOOT
  );

  my $dir = $self->notes('build_data')->{directory};
  chdir $dir;

  # do not reconfigure unless necessary
  # print $cmd, "\n";
  if (not -f 'Makefile') {
    system(@cmd) and die "Build failed while running '@cmd': $?";
  }
  my $make = $self->notes('build_data')->{make};
  system($make) and die "Build failed while running '$make': $?";
  chdir $ORIG_DIR;
}



1;
