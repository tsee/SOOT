use strict;
use warnings;
use Alien::ROOT;
use ExtUtils::CppGuess;
use ExtUtils::CBuilder;
use Cwd qw(cwd);
use File::Spec;
use Getopt::Long qw(GetOptions);

use constant MAXDEBUGLEVEL => 3;

GetOptions(
  'debug|d:i' => \(my $debuglevel),
  'gdb' => \(my $gdb),
);
$debuglevel = 1 if defined $debuglevel and $debuglevel < 1;
$debuglevel = 3 if defined $debuglevel and $debuglevel > 3;

my $root = Alien::ROOT->new;
$root->installed or die "No ROOT found...";

my $guess = ExtUtils::CppGuess->new(
  extra_compiler_flags => $root->cflags,
  extra_linker_flags => $root->ldflags,
);

$root->setup_environment;

my $libdir = $root->libdir;
opendir my $dh, $libdir or die $!;
use Config ();
my @libs = map {s/\.\Q$Config::Config{dlext}\E$//o; $_}
           grep /\.\Q$Config::Config{dlext}\E$/o && -f File::Spec->catfile($libdir, $_),
           readdir($dh);
closedir $dh;

my %opts = $guess->module_build_options;
if (defined $debuglevel) {
  for (1 .. $debuglevel) {
    $opts{extra_compiler_flags} .= " -DDEBUG$_";
  }
  $opts{extra_compiler_flags} .= " -DDEBUG";
}

my @ccfiles = ('dump_classes.cc', grep !/\bdump_classes\.cc$/, glob('*.cc'));
my $builder = ExtUtils::CBuilder->new;

my @objects = map $builder->compile(
    source => $_,
    'C++' => 1,
    extra_compiler_flags => $opts{extra_compiler_flags} . ' -I. -I.. -I../src',
  ), @ccfiles;

$builder->link_executable(
  objects => \@objects,
  extra_linker_flags => $opts{extra_linker_flags} . " " . join(" ", map "-I$_", map {s/^lib//; $_} @libs),
);

my @args = (File::Spec->catdir(cwd(), 'dump_classes'), @libs);
if ($gdb) {
  #splice @args, 1, 0, '--args';
  unshift @args, 'gdb', '--args';
}

print "Running: @args\n";
system(@args);

