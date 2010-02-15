use strict;
use warnings;
use Data::Dumper;
use autobox::Core;

use SOOT;

# FIXME, pass arrays instead (since that now works)
my $g = TGraphErrors->new(3);
$g->SetPoint(0, 1., 9.);
$g->SetPointError(0, 0.5, 0.5);
$g->SetPoint(1, 3., 4.);
$g->SetPointError(1, 0.5, 0.5);
$g->SetPoint(2, 5., 6.);
$g->SetPointError(2, 0.5, 0.5);
my $cv = TCanvas->new("myCanvas");
$g->Draw("ALP");
$cv->SaveAs("cv.eps");

my $x = $g->GetX();
warn Dumper $x;
