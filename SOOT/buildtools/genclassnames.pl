#!/usr/bin/env perl
use strict;
use warnings;
use File::Spec;
# TODO implement
open my $h_oh, '>', File::Spec->catfile('src', 'SOOTClassnames.h') or die $!;
open my $cc_oh, '>', File::Spec->catfile('src', 'SOOTClassnames.cc') or die $!;

my $nClassNames = 3;

print $h_oh <<HERE;
#ifndef __soot_classnames_h_
#define __soot_classnames_h_

namespace SOOT {
  extern unsigned int gNClassNames;
  extern char* gClassNames[$nClassNames];
} // end namespace SOOT
#endif
HERE

print $cc_oh <<HERE;
#include "SOOTClassnames.h"

namespace SOOT {
  unsigned int gNClassNames = $nClassNames;
  char* gClassNames[$nClassNames] = {
HERE

print $cc_oh qq{    "$_",\n} for qw(TObject TH1 TH1D);

print $cc_oh <<'HERE';
  };
} // end namespace SOOT
HERE

