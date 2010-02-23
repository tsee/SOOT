use 5.008001;
use ExtUtils::MakeMaker;
use lib '..';
use inc::SOOTBuild;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.

WriteMakefile(
  inc::SOOTBuild::GetMMArgs('..'),
  NAME => 'src',
);

