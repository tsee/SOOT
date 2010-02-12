use strict;
use warnings;
use Test::More tests => 7;
use SOOT;
pass();
is_deeply(\@TH1D::ISA, ["TObject"]);

eval { TObject->new(qw(a b c)); };
ok($@ and "$@" =~ /Can't locate object method/);

eval { TH1D->Foo(); };
ok($@ and "$@" =~ /Can't locate object method/);

eval { TAdvancedGraphicsDialog->DoesntExist(); };
ok($@ and "$@" =~ /Can't locate object method/);

# this one actually exists...
eval { TGraph->Clone("newname"); };
ok(not $@);

pass("alive");

