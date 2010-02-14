use strict;
use warnings;
use Test::More tests => 12;
use SOOT;
pass();
is_deeply(\@TH1D::ISA, ["TObject"]);

eval { TObject->new(qw(a b c)); };
ok($@ && "$@" =~ /Can't locate object method/, "Can't locate method...");
diag($@) if $@;

eval { TH1D->Foo(); };
ok($@ && "$@" =~ /Can't locate object method/, "Can't locate method...");
diag($@) if $@;

eval { TAdvancedGraphicsDialog->DoesntExist(); };
ok($@ && "$@" =~ /Can't locate object method/, "Can't locate method...");
diag($@) if $@;

# this one actually exists...
eval { TGraph->Clone("newname"); };
ok(!$@, "No error on TGraph->Clone");
diag($@) if $@;

my $tgraph = eval { TGraph->new(3, [1.,2,3], [1.,2,3]); };
ok(!$@, "No error on TGraph->new");
diag($@) if $@;
ok(defined $tgraph);
isa_ok($tgraph, 'TGraph');
isa_ok($tgraph, 'TObject');

eval { $tgraph->GetN(); };
ok(!$@, "No error on TGraph->GetN");

pass("alive");

