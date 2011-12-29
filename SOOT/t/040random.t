use strict;
use warnings;
use Test::More tests => 8;

use SOOT ':all';

# There could be lots more tests for RNGs here, but the major point
# for now is to test the ->() "assignment" operator.


my $h = TH1D->new("foo", "foo", 10, 0., 1.);
my $h2 = TH1D->new("foo2", "foo2", 10, 0., 1.);
$h->Fill(0.1);
my $c = TCanvas->new;
$h->Draw();

use Data::Dumper;
warn Dumper $h;
warn Dumper $h2;

warn Dumper([$h2->($h)]);
warn Dumper $h;
warn Dumper $h2;
my $c2 = TCanvas->new;
$h2->Draw();
$gApplication->Run();

isa_ok($gRandom, "TRandom");
# match exact class, too
# (It's really a TRandom3, but we force the container to be a TRandom during SetPerlGlobal.
#  It's a bit of a hack, really, but it allows us to use the assignment ops. I think.)
is(ref($gRandom), "TRandom");

my $r1 = TRandom->new(12);
my $r2 = TRandom2->new(0);

use Data::Dumper;
warn Dumper $gRandom;
$gRandom->($r1);

isa_ok($gRandom, "TRandom");
is(ref($gRandom), "TRandom");

$gRandom->($r2);
isa_ok($gRandom, "TRandom");
TODO: {
  local $TODO = "Weird, I think this should remain a TRandom2. Needs some more proper thinking.";
  isa_ok($gRandom, "TRandom2");
}

is(ref($gRandom), "TRandom");
warn Dumper $gRandom;
$gRandom->($r2);
my $rnd = $gRandom->Rndm();
$gRandom->($r2);
approx_eq($rnd, $gRandom->Rndm(), "Output of reset RNG remains the same");
approx_ne($rnd, $gRandom->Rndm(), "Output of next random number differs");
pass("alive");

sub approx_eq {
  my $l = shift;
  my $r = shift;
  ok($r > $l-1.e-9 && $r < $l+1.e-9, shift(@_) . ", left: $l, right: $r");
}

sub approx_ne {
  my $l = shift;
  my $r = shift;
  ok($r > $l+1.e-9 || $r < $l-1.e-9, shift(@_) . ", left: $l, right: $r");
}

