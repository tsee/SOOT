#!/usr/bin/env perl
use strict;
use warnings;
use inc::latest;

#                        Module::Build
foreach my $module (qw( ExtUtils::XSpp
                        ExtUtils::Typemap
                        ExtUtils::ParseXS
                    ))
{
  inc::latest->bundle_module($module, 'inc');
}

