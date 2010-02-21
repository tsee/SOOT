use strict;
use warnings;
use SOOT ':all';

# display the various 2-d drawing options
$gROOT->Reset();
$gStyle->SetOptStat(0);
$gStyle->SetPalette(1);
$gStyle->SetCanvasColor(33);
$gStyle->SetFrameFillColor(18);

my $pl = TPaveLabel->new();

my $f2 = TF2->new("f2","xygaus + xygaus(5) + xylandau(10)",-4,4,-4,4);
my @params = (130,-1.4,1.8,1.5,1, 150,2,0.5,-2,0.5, 3600,-2,0.7,-3,0.3);
for (my $i = 0; $i < scalar @params; $i++) {
 $f2->SetParameter($i, $params[$i]);
}
my $h2 = TH2F->new("h2","xygaus + xygaus(5) + xylandau(10)",20,-4,4,20,-4,4);
$h2->SetFillColor(46);
$h2->FillRandom("f2",40000);

# basic 2-d options
my $x1 = 0.67; 
my $y1 = 0.875; 
my $x2 = 0.85; 
my $y2 = 0.95;
my $cancolor = 17;

my $c2h = TCanvas->new("c2h","2-d options",10,10,800,600);
$c2h->Divide(2,2);
$c2h->SetFillColor($cancolor);
$c2h->cd(1);
$h2->Draw();       
$pl->DrawPaveLabel($x1,$y1,$x2,$y2,"SCAT","brNDC");
$c2h->cd(2);
$h2->Draw("box");  
$pl->DrawPaveLabel($x1,$y1,$x2,$y2,"BOX","brNDC");
$c2h->cd(3);
$h2->Draw("arr");  
$pl->DrawPaveLabel($x1,$y1,$x2,$y2,"ARR","brNDC");
$c2h->cd(4);
$h2->Draw("colz"); 
$pl->DrawPaveLabel($x1,$y1,$x2,$y2,"COLZ","brNDC");
$c2h->Update();

# text option
my $ctext = TCanvas->new("ctext","text option",50,50,800,600);
$gPad->SetGrid();
$ctext->SetFillColor($cancolor);
$ctext->SetGrid();
$h2->Draw("text"); 
$pl->DrawPaveLabel($x1,$y1,$x2,$y2,"TEXT","brNDC");
$ctext->Update();

# contour options
my $cont = TCanvas->new("contours","contours",100,100,800,600);
$cont->Divide(2,2);
$gPad->SetGrid();
$cont->SetFillColor($cancolor);
$cont->cd(1);
$h2->Draw("contz"); 
$pl->DrawPaveLabel($x1,$y1,$x2,$y2,"CONTZ","brNDC");
$cont->cd(2);
$gPad->SetGrid();
$h2->Draw("cont1"); 
$pl->DrawPaveLabel($x1,$y1,$x2,$y2,"CONT1","brNDC");
$cont->cd(3);
$gPad->SetGrid();
$h2->Draw("cont2"); 
$pl->DrawPaveLabel($x1,$y1,$x2,$y2,"CONT2","brNDC");
$cont->cd(4);
$gPad->SetGrid();
$h2->Draw("cont3"); 
$pl->DrawPaveLabel($x1,$y1,$x2,$y2,"CONT3","brNDC");
$cont->Update();

#lego options
my $lego = TCanvas->new("lego","lego options",150,150,800,600);
$lego->Divide(2,2);
$lego->SetFillColor($cancolor);
$lego->cd(1);
$h2->Draw("lego");     
$pl->DrawPaveLabel($x1,$y1,$x2,$y2,"LEGO","brNDC");
$lego->cd(2);
$h2->Draw("lego1");    
$pl->DrawPaveLabel($x1,$y1,$x2,$y2,"LEGO1","brNDC");
$lego->cd(3);
$gPad->SetTheta(61); 
$gPad->SetPhi(-82);
$h2->Draw("surf1pol"); 
$pl->DrawPaveLabel($x1,$y1,$x2+0.05,$y2,"SURF1POL","brNDC");
$lego->cd(4);
$gPad->SetTheta(21); 
$gPad->SetPhi(-90);
$h2->Draw("surf1cyl"); 
$pl->DrawPaveLabel($x1,$y1,$x2+0.05,$y2,"SURF1CYL","brNDC");
$lego->Update();

# surface options
my $surf = TCanvas->new("surfaces","surface options",200,200,800,600);
$surf->Divide(2,2);
$surf->SetFillColor($cancolor);
$surf->cd(1);
$h2->Draw("surf1");   
$pl->DrawPaveLabel($x1,$y1,$x2,$y2,"SURF1","brNDC");
$surf->cd(2);
$h2->Draw("surf2z");  
$pl->DrawPaveLabel($x1,$y1,$x2,$y2,"SURF2Z","brNDC");
$surf->cd(3);
$h2->Draw("surf3");   
$pl->DrawPaveLabel($x1,$y1,$x2,$y2,"SURF3","brNDC");
$surf->cd(4);
$h2->Draw("surf4");   
$pl->DrawPaveLabel($x1,$y1,$x2,$y2,"SURF4","brNDC");
$surf->Update();

$gApplication->Run;