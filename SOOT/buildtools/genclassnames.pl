#!/usr/bin/env perl
use strict;
use warnings;
use File::Spec;
# TODO implement
open my $oh, '>', File::Spec->catfile('src', 'soot_classnames.h') or die $!;

my $nClassNames = 3;
print $oh <<HERE;
#ifndef __soot_classnames_h_
#define __soot_classnames_h_

namespace SOOT {
  const unsigned int gNClassNames = $nClassNames;
  char* gClassNames[gNClassNames] = {
HERE

print $oh qq{    "$_",\n} for qw(TObject TH1 TH1D);

print $oh <<'HERE'
  };
} // end namespace SOOT
#endif
HERE

