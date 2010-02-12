use strict;
use warnings;
use Test::More tests => 3;
use SOOT;
pass();
is_deeply(\@TH1D::ISA, ["TObject"]);

TObject->Foo();
TH1D->Foo();
TAdvancedGraphicsDialog->DoesntExist();
pass("alive");

