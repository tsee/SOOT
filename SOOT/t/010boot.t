use strict;
use warnings;
use Test::More tests => 12;
use SOOT;
pass();
is_deeply(\@TH1D::ISA, ["TObject"]);

eval { TObject->new(qw(a b c)); };
ok($@ && "$@" =~ /Can't locate method/, "Can't locate method...");
diag($@) if $@;

eval { TH1D->Foo(); };
ok($@ && "$@" =~ /Can't locate method/, "Can't locate method...");
diag($@) if $@;

eval { TAdvancedGraphicsDialog->DoesntExist(); };
ok($@ && "$@" =~ /Can't locate method/, "Can't locate method...");
diag($@) if $@;

my $tgraph = eval { TGraph->new(12); };
#my $tgraph = eval { TGraph->new(3, [1.,2,3], [1.,2,3]); };
ok(!$@, "No error on TGraph->new");
diag($@) if $@;
use Data::Dumper; warn Dumper $tgraph;
ok(defined $tgraph);
isa_ok($tgraph, 'TGraph');
isa_ok($tgraph, 'TObject');

my $n = eval { $tgraph->GetN(); };
ok(!$@, "No error on TGraph->GetN");
ok((defined $n) && ($n == 12), "GetN works!");
undef $tgraph;

pass("alive");

