use strict;
use warnings;

use Getopt::Long;
use inc::latest 'ExtUtils::Typemap';
use inc::latest 'ExtUtils::ParseXS';
use inc::latest 'ExtUtils::XSpp';
use inc::latest 'Module::Build';

use lib 'inc';
use SOOTBuilder;

my $userRootConfig;
my @flags;
my @libs;

GetOptions(
  '--with-root-config:s' => \$userRootConfig,
  '--build-debug' => sub {push(@flags, '-DDEBUG')},
);

# The bindings should be compiled with the flags for libsmokeqt and qt4
push(@flags,
  '-std=gnu++98', # FIXME necessary?
  '-Wall',
  '-xc++',
  '-I.',
  '-Isrc',
#  '-C++', # from Makefile.PL
#  '-hiertype', # from Makefile.PL
);

my $rootConfig = defined($userRootConfig) ? $userRootConfig : 'root-config';
if (!SOOTBuilder::can_run($rootConfig)) {
  $rootConfig = File::Spec->catfile($ENV{ROOTSYS}, 'bin', 'root-config');
  if (!SOOTBuilder::can_run($rootConfig)) {
    die <<HERE;
Could not find the root-config utility which is necessary for building
SOOT. You can either make sure it's available from your PATH environment,
set the ROOTSYS environment variable correctly, or run Build.PL with
  perl Build.PL --with-root-config=/path/to/root-config
HERE
  }
}

push @flags, split(' ', SOOTBuilder::striprun($rootConfig, '--cflags')),
             (defined $ENV{ROOTSYS}
              ? ('-I'.File::Spec->catdir($ENV{ROOTSYS}, 'include'),
                 '-I'.File::Spec->catdir($ENV{ROOTSYS}, 'include', 'root'))
              : ());
push @libs, map { split(' ', $_) }
             ($Config::Config{lddlflags},
              SOOTBuilder::striprun($rootConfig, '--ldflags'),
              SOOTBuilder::striprun($rootConfig, '--libs'));

# FIXME understand option
## Add an rpath to the .so to make sure it can find libsmokeqt after install
#push(@libs, '-Wl,--rpath,' . Alien::QtSmoke->lib());

my $builder = SOOTBuilder->new(
  module_name           => 'SOOT',
  license               => 'gpl',
  dist_author           => 'Steffen Mueller <smueller@cpan.org>',
  dist_version_from     => 'lib/SOOT.pm',
  dynamic_config        => 1,
  create_readme         => 1,
  recursive_test_files  => 1,
  create_packlist       => 1,

  # Maintain compatibility with ExtUtils::MakeMaker installations
  #create_makefile_pl    => 'passthrough',

  # Location of our special C and XS source files
  c_source => 'src',
  xs_files => {
    'SOOT.xs' => 'lib/SOOT.xs'
  },

  extra_compiler_flags  => \@flags,
  extra_linker_flags    => \@libs,

  requires => {
    'perl'                  => '5.008',
    'Data::Dumper'          => '0', # core as of 5.008

    # Pragmatic and special modules
    'Carp'                  => '1.01', # core as of 5.008
    'version'               => '0',
    'warnings'              => '0', # core as of 5.008
    'strict'                => '0', # core as of 5.008
  },
  build_requires => {
    # For the XS build process
    'ExtUtils::XSpp'        => '0.07',
    'ExtUtils::CBuilder'    => '0',
    'ExtUtils::ParseXS'     => '0',
    'ExtUtils::Constant'    => '0', # core as of 5.008
    'ExtUtils::Typemap'     => '0.04',
    'File::Spec'            => '0', # core as of 5.008
    'File::Path'            => '0', # core as of 5.008
  },

  add_to_cleanup => [ qw(rootclasses.xsinclude rootclasses.h rootclasses.map) ],
  script_files => [],

  meta_merge => {
    resources => {
      # Official keys (homepage, license, bugtracker)
      repository   => 'git://github.com/tsee/SOOT.git',
      bugtracker   => 'http://rt.cpan.org/NoAuth/Bugs.html?Dist=SOOT',
      license      => 'http://www.opensource.org/licenses/gpl-2.0.php',
    },
    no_index => {
      directory => [
        qw(buildtools src t ROOT_XSP xt XS inc examples)
      ],
    },
  },
);

$builder->create_build_script();

