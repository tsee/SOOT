use strict;
use warnings;
use Test::More tests => 3;
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

warn "after";
$go = <STDIN>;
