use strict;
use warnings;
use Test::More tests => 3;
use SOOT;
pass();
is_deeply(\@TObject::ISA, ["SOOT::Base"]);

TObject->Foo();
pass("alive");

