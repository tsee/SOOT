use strict;
use warnings;
use File::Spec;
use ExtUtils::Constant 'WriteConstants';

# tool to generate the necessary code for wrapping ROOT
# constants

my $loadNamespace = 'SOOT::Constants';
my $realNamespace = 'SOOT';

my @consts = qw(
  kWhite kBlack kGray
  kRed    kGreen kBlue kYellow kMagenta kCyan
  kOrange kSpring kTeal kAzure kViolet kPink
  kSolid kDashed kDotted kDashDotted
  kDot kPlus kStar kCircle kMultiply
  kFullDotSmall kFullDotMedium kFullDotLarge
  kFullCircle kFullSquare kFullTriangleUp
  kFullTriangleDown kOpenCircle kOpenSquare kOpenTriangleUp
  kOpenDiamond kOpenCross kFullStar kOpenStar
);

open my $oh_pm, '>', File::Spec->catfile('lib', 'SOOT', 'Constants.pm') or die $!;
print $oh_pm <<HERE;
package $loadNamespace;
use 5.008; use strict; use warnings;
# WARNING: Autogenerated file, do not edit!

my \@Names = qw(
@consts
);
package
  $realNamespace;
HERE

print $oh_pm "sub $_;\n" for @consts;

print $oh_pm <<HERE;

package
  $loadNamespace;
1;
HERE

WriteConstants(
  NAME         => $realNamespace,
  NAMES        => \@consts,
  DEFAULT_TYPE => 'IV',
  C_FILE       => 'const-c.inc',
  XS_FILE      => 'const-xs.inc',
);

