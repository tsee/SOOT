use strict;
use warnings;
use Test::More tests => 2;
use SOOT;
pass("alive");

warn "before";
my $go = <STDIN>;

=pod

foreach (1..1e6) {
  my $scalar;
  my $obj;
  $obj = bless(\$scalar => 'TObject');
  SOOT::type($obj);
  $obj = bless(\$scalar => 'TH1D');
  SOOT::type($obj);
  $obj = bless([] => 'TObject');
  SOOT::type($obj);
  $obj = bless([] => 'TH1D');
  SOOT::type($obj);
  $obj = bless({} => 'TObject');
  SOOT::type($obj);
  $obj = bless({} => 'TH1D');
  SOOT::type($obj);
  $obj = bless({} => 'Something::Else');
  SOOT::type($obj);
}

=cut

=pod

foreach (1..1e6) {
  my $scalar;
  my $obj;
  $obj = bless(\$scalar => 'TObject');
  SOOT::cproto($obj);
  $obj = bless(\$scalar => 'TH1D');
  SOOT::cproto($obj);
  $obj = bless([] => 'TObject');
  SOOT::cproto($obj);
  $obj = bless([] => 'TH1D');
  SOOT::cproto($obj);
  $obj = bless({} => 'TObject');
  SOOT::cproto($obj);
  $obj = bless({} => 'TH1D');
  SOOT::cproto($obj);
  $obj = bless({} => 'Something::Else');
  SOOT::cproto($obj);
}

=cut


=pod

# doesn't leak 2010-02-17
my $obj = TGraph->new(12);
foreach (1..1e6) {
  $obj->GetN()
}

=cut


=pod

# doesn't leak 2010-02-17
my $obj = TGraph->new(12);
my $obj2 = TH1D->new("a","a",2,0.,1.);
foreach (1..1e6) {
  $obj->SetHistogram($obj2);
}

=cut

=pod

# doesn't leak 2010-02-17
foreach (1..1e6) {
  my $obj = TH1D->new("hist".$_, "hist".$_, 10, 0., 1.);
  undef $obj;
}

=cut

=pod

# doesn't leak 2010-02-17
foreach (1..1e6) {
  my $obj = TH1D->new("hist".$_, "hist".$_, 10, 0., 1.);
  $obj->GetXaxis();
}

=cut

warn "after";
$go = <STDIN>;
pass("alive");

