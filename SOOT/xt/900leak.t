use strict;
use warnings;
use Test::More tests => 2;
use SOOT;
use Time::HiRes qw/sleep/;
pass("alive");

warn "before";
my $go = <STDIN>;

=pod

# doesn't leak at e19f62548881a14be485f8ed56c59a1d32f00d61 (2010-02-22)
# doesn't leak at fe99b3f6e7ed25c3b9d4e6e388818f860445673c (GC)
foreach (1..1e6) {
  my $scalar;
  my $obj;
  $obj = bless(\$scalar => 'TObject');
  SOOT::API::type($obj);
  $obj = bless(\$scalar => 'TH1D');
  SOOT::API::type($obj);
  $obj = bless([] => 'TObject');
  SOOT::API::type($obj);
  $obj = bless([] => 'TH1D');
  SOOT::API::type($obj);
  $obj = bless({} => 'TObject');
  SOOT::API::type($obj);
  $obj = bless({} => 'TH1D');
  SOOT::API::type($obj);
  $obj = bless({} => 'Something::Else');
  SOOT::API::type($obj);
}

=cut

=pod

# doesn't leak at fe99b3f6e7ed25c3b9d4e6e388818f860445673c (GC)
foreach (1..1e6) {
  my $scalar;
  my $obj;
  $obj = bless(\$scalar => 'TObject');
  SOOT::API::cproto($obj);
  $obj = bless(\$scalar => 'TH1D');
  SOOT::API::cproto($obj);
  $obj = bless([] => 'TObject');
  SOOT::API::cproto($obj);
  $obj = bless([] => 'TH1D');
  SOOT::API::cproto($obj);
  $obj = bless({} => 'TObject');
  SOOT::API::cproto($obj);
  $obj = bless({} => 'TH1D');
  SOOT::API::cproto($obj);
  $obj = bless({} => 'Something::Else');
  SOOT::API::cproto($obj);
}

=cut


=pod

# doesn't leak at fe99b3f6e7ed25c3b9d4e6e388818f860445673c (GC)
# doesn't leak at e19f62548881a14be485f8ed56c59a1d32f00d61 (2010-02-22)
# doesn't leak 2010-02-17
my $obj = TGraph->new(12);
foreach (1..1e6) {
  $obj->GetN()
}

=cut


=pod

# doesn't leak at fe99b3f6e7ed25c3b9d4e6e388818f860445673c (GC)
# doesn't leak at e19f62548881a14be485f8ed56c59a1d32f00d61 (2010-02-22)
# doesn't leak 2010-02-17
my $obj = TGraph->new(12);
my $obj2 = TH1D->new("a","a",2,0.,1.);
foreach (1..1e6) {
  $obj->SetHistogram($obj2);
}

=cut


=pod

# doesn't leak at 521258e980d7fa7f34a96df4620943210121341a (GC heuristics)
# FIXME LEAKS AT fe99b3f6e7ed25c3b9d4e6e388818f860445673c (GC)
# FIXME LEAKS AT e19f62548881a14be485f8ed56c59a1d32f00d61 (2010-02-22)
# doesn't leak 2010-02-17
foreach (1..1e6) {
  my $obj = TH1D->new("hist".$_, "hist".$_, 10, 0., 1.);
  undef $obj;
}

=cut


=pod

# doesn't leak at 521258e980d7fa7f34a96df4620943210121341a (GC heuristics)
# doesn't leak 2010-02-17
foreach (1..1e6) {
  my $obj = TH1D->new("hist".$_, "hist".$_, 10, 0., 1.);
  $obj->GetXaxis();
  undef $obj;
}

=cut


=pod

# doesn't leak at 521258e980d7fa7f34a96df4620943210121341a (GC heuristics)
# doesn't leak 2010-02-20
my $obj = TGraph->new(1e4, [(1) x 1e4], [(2) x 1e4]);
foreach (1..1e8) {
  my $x = $obj->GetX();
  undef $x;
}

=cut

=pod

# doesn't leak at 521258e980d7fa7f34a96df4620943210121341a (GC heuristics)
# leaks like a sieve 2010-02-20 (despite the underlying object being deleted)
# stops leaking with aada56a1b7564a4e4cdbe08fc6ec82bc3e92693c (2010-02-20)
sub test {
  my $obj = TGraph->new(1e2, [(1) x 1e2], [(2) x 1e2]);
  undef $obj;
}

foreach (1..1e8) {
  test(); 
}

=cut

=pod

# doesn't leak at 521258e980d7fa7f34a96df4620943210121341a (GC heuristics)
# stops leaking with 4f8540b820a41eca097e8556d705f9220bd8dad7 (2010-02-20)
my $obj = TH1D->new("blah", "blah", 10, 0., 1.);
foreach (1..1e8) {
  my $x = $obj->GetNbinsX();
  undef $x;
}

=cut

warn "done";
$go = <STDIN>;
pass("alive");

