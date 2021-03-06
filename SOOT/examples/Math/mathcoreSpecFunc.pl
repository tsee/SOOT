use strict;
use warnings;
use SOOT ':all';

# Example macro describing how to use the special mathematical functions
# taking full advantage of the precision and speed of the C99 compliant
# environments. To execute the macro type in:
#
# root[0]: .x mathcoreSpecFunc.C 
#
# It will create two canvases: 
#
#   a) one with the representation of the tgamma, lgamma, erf and erfc functions
#   b) one with the relative difference between the old ROOT versions and the
#      C99 implementation (on obsolete platform+compiler combinations which are
#      not C99 compliant it will call the original ROOT implementations, hence
#      the difference will be 0)
#
# The naming and numbering of the functions is taken from
# <A HREF="http:#www.open-std.org/jtc1/sc22/wg21/docs/papers/2004/n1687.pdf">
# Matt Austern,
# (Draft) Technical Report on Standard Library Extensions,
# N1687=04-0127, September 10, 2004</A>
#
#  Author: Andras Zsenei

$gSystem->Load("libMathCore");
my $f1a = TF1->new("f1a","ROOT::Math::tgamma(x)",0,100);
my $f1b = TF1->new("f1b","TMath::Abs((ROOT::Math::tgamma(x)-TMath::Gamma(x))/ROOT::Math::tgamma(x))",0,100);

my $f2a = TF1->new("f2a","ROOT::Math::lgamma(x)",0,100);
my $f2b = TF1->new("f2b","TMath::Abs((ROOT::Math::lgamma(x)-TMath::LnGamma(x))/ROOT::Math::lgamma(x))",0,100);

my $f3a = TF1->new("f3a","ROOT::Math::erf(x)",0,5);
my $f3b = TF1->new("f3b","TMath::Abs((ROOT::Math::erf(x)-TMath::Erf(x))/ROOT::Math::erf(x))",0,5);

my $f4a = TF1->new("f4a","ROOT::Math::erfc(x)",0,5);
my $f4b = TF1->new("f4b","TMath::Abs((ROOT::Math::erfc(x)-TMath::Erfc(x))/ROOT::Math::erfc(x))",0,5);


my $c1 = TCanvas->new("c1","c1",1000,750);
$c1->Divide(2,2);

$c1->cd(1);
$f1a->Draw();
$c1->cd(2);
$f2a->Draw();
$c1->cd(3);
$f3a->Draw();
$c1->cd(4);
$f4a->Draw();


my $c2 = TCanvas->new("c2","c2",1000,750);
$c2->Divide(2,2);

$c2->cd(1);
$f1b->Draw();
$c2->cd(2);
$f2b->Draw();
$c2->cd(3);
$f3b->Draw();
$c2->cd(4);
$f4b->Draw();

$gApplication->Run;
