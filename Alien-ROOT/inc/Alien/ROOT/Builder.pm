package Alien::ROOT::Builder;

use strict;
use warnings;

use base 'Module::Build';

use Cwd ();
use Carp ();

my $ORIG_DIR = Cwd::cwd();

# These are utility commands for getting into and out of our build directory
sub _chdir_or_die {
  use File::Spec ();
  my $dir = File::Spec->catfile(@_);
  chdir $dir or Carp::croak("Failed to chdir to $dir: $!");
}
sub _chdir_back {
  chdir $ORIG_DIR or Carp::croak("Failed to chdir to $ORIG_DIR: $!");
}

sub ACTION_code {
  my ($self) = @_;

  my $rc = $self->SUPER::ACTION_code;
  if ($self->notes('build_ROOT')) {
    if ($self->notes('extra')) {
      _chdir_or_die('libjio');
    }
    else {
      _chdir_or_die('libjio', 'libjio');
    }

    # Run the make system to do the rest, but save the return code
    system($self->notes('make'));
    $rc = $? >> 8;

    # Make sure we change the directory back before adding notes, or they
    # won't persist (in _build state)
    _chdir_back();
    $self->notes(build_result => $rc);
  }

  return $rc;
}

sub ACTION_install {
  my ($self) = @_;

  my $rc = $self->SUPER::ACTION_install;
  if ($self->notes('build_ROOT')) {
    # Get into our build directory
    if ($self->notes('extra')) {
      _chdir_or_die('libjio');
    }
    else {
      _chdir_or_die('libjio', 'libjio');
    }

    # Run the make system to do the rest
    $rc = (system($self->notes('make'), 'install') == 0) ? 1 : 0;
    _chdir_back();
  }

  return $rc;
}

sub ACTION_clean {
  my ($self) = @_;

  my $rc = $self->SUPER::ACTION_clean;
  _chdir_or_die('libjio');
  $rc = (system($self->notes('make'), 'clean') == 0) ? 1 : 0;
  _chdir_back();

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

1;