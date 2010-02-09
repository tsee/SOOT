use 5.010000;
use ExtUtils::MakeMaker;
use File::Spec;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.

my $CC = 'g++';

# todo move to later build stage
system($^X, File::Spec->catfile('buildtools', 'genclassnames.pl')) and die $!;

WriteMakefile(
    NAME              => 'SOOT',
    VERSION_FROM      => 'lib/SOOT.pm', # finds $VERSION
    PREREQ_PM         => {
    }, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/SOOT.pm', # retrieve abstract from module
       AUTHOR         => 'Steffen Mueller <smueller@cpan.org>') : ()),
    LIBS              => [join ' ', qw()], # e.g., '-lm'
    DEFINE            => '', # e.g., '-DHAVE_SOMETHING'
    INC               => '-I. -Isrc', # e.g., '-I. -I/usr/include/other'
    OBJECT            => '$(O_FILES)', # link all the C files too
    'XSOPT'             => '-C++ -hiertype',
    'TYPEMAPS'          => ['perlobject.map'],
    'CC'                => $CC,
    'LD'                => '$(CC)',
    META_MERGE => { no_index => { directory => 'buildtools', }, },
    clean => {
      FILES => "src/soot_classnames.h",
    },
);

