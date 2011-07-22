use strict;
use warnings;
use Test::More;
use SOOT;
use SOOT::API qw/:all/;

my $th1d = TH1D->new("foo", "bar", 10, 0., 10.);
isa_ok($th1d, $_) for qw(TH1D TH1 TObject); 

my $clone = $th1d->Clone;
isa_ok($clone, $_) for qw(TH1D TH1 TObject); 

#my $cv = TCanvas->new;
$|=1;
print STDERR "#";
$clone = $th1d->DrawClone("l"); # Damn chatty ROOT
print STDERR "#\n";
isa_ok($clone, $_) for qw(TH1D TH1 TObject); 

done_testing();