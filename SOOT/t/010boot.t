use strict;
use warnings;
use Test::More tests => 2;
use SOOT;
pass();
is_deeply(\@TObject::ISA, ["SOOT::Base"]);

