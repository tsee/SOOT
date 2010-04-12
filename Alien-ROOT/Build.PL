#!/usr/bin/perl
use 5.008;
use strict;
use warnings;

use lib 'inc';
use Alien::ROOT::Builder;

use Env '@PATH';

our $USER_CONFIG = {
  archive => 'root_v5.26.00.source.tar.gz',
};


my $builder = Alien::ROOT::Builder->new(
  module_name           => 'Alien::ROOT',
  license               => 'unrestricted',
  dist_author           => 'Steffen Mueller <smueller@cpan.org>',
  dist_version_from     => 'lib/Alien/ROOT.pm',
  dynamic_config        => 1,
  create_readme         => 1,

  # Maintain compatibility with ExtUtils::MakeMaker installations
  create_makefile_pl    => 'passthrough',

  requires => {
    'perl'                => 5.008,
    'ExtUtils::MakeMaker' => 0,
    'File::Spec'          => 0,
    'File::Path'          => 0,
    'Capture::Tiny'       => 0, # TODO: bundle somehow? Use IPC::Open2/3?
  },
  build_requires => {
    'Test::More'              => 0.62,
    'ExtUtils::CBuilder'      => 0,
    'File::Fetch'             => 0, # TODO: bundle and setup bundling logic
    'Archive::Extract'        => 0, # TODO: bundle and setup bundling logic
  },

  add_to_cleanup => [ 'Alien-ROOT-*' ],
  script_files => [],

  meta_merge => {
    resources => {
      Ratings      => 'http://cpanratings.perl.org/d/Alien-ROOT',
      repository   => 'git://github.com/tsee/ROOT.git',
      bugtracker   => 'http://rt.cpan.org/NoAuth/Bugs.html?Dist=Alien-ROOT',
      license      => 'http://www.opensource.org/licenses/gpl-2.0.php',
    },
  },
);

my $build_data = {%$USER_CONFIG};
$build_data->{url} = 'ftp://root.cern.ch/root/' . $build_data->{archive};
$build_data->{directory} = 'root'; # this is pretty retarded :(

$builder->notes('build_data' => $build_data);

# Use Alien::ROOT to see if it's already installed
use lib 'lib';
use Alien::ROOT;

my $aroot = Alien::ROOT->new();

unless ($aroot->installed) {
  # Ask the user if they'd like to install this; if not, then exit
  $builder->y_n('ROOT was not found on your system. Install it now?', 'y')
    or exit;

  $builder->notes(build_ROOT => 1);

  # Ask the user what 'make' program to invoke
  my $make;
  if (exists($ENV{MAKE}) && length($ENV{MAKE})) {
    $make = $ENV{MAKE};
  }
  else {
    use Config '%Config';
    $make = $Config{make};

    # Probe for GNU Make (useful on BSD/Unix variants)
    if ($make eq 'make' && grep { -x $_ . '/gmake' } @PATH) {
      $make = 'gmake';
      if ($^O =~ /bsd$/) {
        print {*STDERR} "warning: your system is a BSD variant but " .
          "gmake wasn't found.\n";
      }
    }
  }
  if (not defined $make or not $aroot->_can_run($make)) { # FIXME hack
    $make = $builder->prompt('What is your system "make" command?', $make);
  }

  $builder->notes(make => $make);

#  # Figure out if we should do a full install
#  my $extra = $builder->y_n('ROOT includes other files. Install them too?', 'n');
#  $builder->notes(extra => $extra);
}

$builder->create_build_script();
