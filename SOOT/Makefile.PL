use 5.010000;
use ExtUtils::MakeMaker;
use lib '.';
use inc::SOOTBuild;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.

my $CC = 'g++';

# todo move to later build stage
system($^X, File::Spec->catfile('buildtools', 'genclassnames.pl')) and die $!;

WriteMakefile(
    inc::SOOTBuild::GetMMArgs('.'),
    NAME              => 'SOOT',
    VERSION_FROM      => 'lib/SOOT.pm', # finds $VERSION
    PREREQ_PM         => {
      'ExtUtils::XSpp' => '0.07',
    }, # e.g., Module::Name => 1.1
    ABSTRACT_FROM     => 'lib/SOOT.pm', # retrieve abstract from module
    AUTHOR            => 'Steffen Mueller <smueller@cpan.org>',
    META_MERGE => { no_index => { directory => 'buildtools', }, },
    clean => {
      FILES => "src/SOOTClassnames.cc",
    },
);

