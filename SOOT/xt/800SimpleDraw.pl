use strict;
use warnings;

use SOOT;

my $g = TGraph->new(3);
$g->SetPoint(0, 1., 9.);
$g->SetPoint(1, 3., 4.);
$g->SetPoint(2, 5., 6.);
my $t = TCanvas->new("myCanvas");
$g->Draw("ALP");
$t->SaveAs("t.eps");


