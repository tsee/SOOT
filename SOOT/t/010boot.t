use strict;
use warnings;
use Test::More tests => 6;
use SOOT;
pass();
is_deeply(\@TH1D::ISA, ["TObject"]);

eval { TObject->new(); };
ok(not $@);

eval { TH1D->Foo(); };
ok(not $@);

eval { TAdvancedGraphicsDialog->DoesntExist(); };
ok($@ and "$@" =~ /Can't locate object method/);

pass("alive");

