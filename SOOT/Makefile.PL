# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
use 5.008001;
use lib '.';
use inc::latest 'ExtUtils::XSpp';
use inc::latest 'ExtUtils::ParseXS';
use Config;
use File::Spec;
# bootstrap the bundled toolchain
BEGIN {
  if ($INC{"ExtUtils/ParseXS.pm"} =~ /\binc\b/) {
    $ENV{PATH} = "buildtools" . $Config::Config{path_sep} . $ENV{PATH};
  }
}

use ExtUtils::MakeMaker;

unshift @INC, 'inc';
require inc::SOOTBuild;

my $CC = 'g++';

# todo move to later build stage
system($^X, '-I.', '-Iinc', File::Spec->catfile('buildtools', 'genclassnames.pl')) and die $!;
system($^X, '-I.', '-Iinc', File::Spec->catfile('buildtools', 'gen_root_xsp_include.pl')) and die $!;
system($^X, '-I.', '-Iinc', File::Spec->catfile('buildtools', 'genconstants.pl')) and die $!;

WriteMakefile(
    inc::SOOTBuild::GetMMArgs('.'),
    NAME              => 'SOOT',
    VERSION_FROM      => 'lib/SOOT.pm', # finds $VERSION
    PREREQ_PM         => {
      'ExtUtils::XSpp' => '0.07',
      'ExtUtils::Constant' => '0', # core as of 5.008
      'Data::Dumper' => '0', # core as of 5.008
    }, # e.g., Module::Name => 1.1
    ABSTRACT_FROM     => 'lib/SOOT.pm', # retrieve abstract from module
    AUTHOR            => 'Steffen Mueller <smueller@cpan.org>',
    META_MERGE => { no_index => { directory => [qw(buildtools inc)], }, },
    clean => {
      FILES => "src/SOOTClassnames.cc rootclasses.xsinclude rootclasses.h rootclasses.map",
    },
);


