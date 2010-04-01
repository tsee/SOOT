#!/usr/bin/env perl
use strict;
use warnings;
use inc::latest;

#                        Module::Build
#                        ExtUtils::ParseXS
#                        ExtUtils::Typemap
foreach my $module (qw( ExtUtils::XSpp
                        ExtUtils::CBuilder
                    ))
{
  inc::latest->bundle_module($module, 'inc');
}

