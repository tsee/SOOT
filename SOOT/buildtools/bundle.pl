#!/usr/bin/env perl
use strict;
use warnings;
use inc::latest;

#                        Module::Build
#                        ExtUtils::ParseXS
#                        ExtUtils::Typemap
#                        Alien::ROOT
foreach my $module (qw( ExtUtils::XSpp
                        ExtUtils::CBuilder
                        Alien::ROOT
                    ))
{
  inc::latest->bundle_module($module, 'inc');
}

