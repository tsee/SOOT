use strict;
use warnings;
use Test::More tests => 24;
use SOOT;
pass();

is(SOOT::type("foo"), "STRING");
is(SOOT::type(9), "INTEGER");
is(SOOT::type(9.1), "FLOAT");

my $int = 2;
my $float = 3.1;
my $str = "fooo";

is(SOOT::type($str), "STRING");
is(SOOT::type($int), "INTEGER");
is(SOOT::type($float), "FLOAT");

my $foo = "123";
is(SOOT::type($foo), "STRING");

$foo = "123"+2;
is(SOOT::type($foo), "INTEGER");

$foo = "123.2"+2;
is(SOOT::type($foo), "FLOAT");

$foo = (.2*3.3)."";
is(SOOT::type($foo), "STRING");
is(SOOT::type($foo*$foo), "FLOAT");

is(SOOT::type([]), 'ARRAY');
is(SOOT::type({}), 'HASH');
is(SOOT::type(sub {}), 'CODE');
is(SOOT::type(\1), 'REF');
is(SOOT::type(\$foo), 'REF');

my $scalar;
my $obj;
$obj = bless(\$scalar => 'TObject');
is(SOOT::type($obj), 'TOBJECT');
$obj = bless(\$scalar => 'TH1D');
is(SOOT::type($obj), 'TOBJECT');

$obj = bless([] => 'TObject');
is(SOOT::type($obj), 'TOBJECT');
$obj = bless([] => 'TH1D');
is(SOOT::type($obj), 'TOBJECT');


$obj = bless({} => 'TObject');
is(SOOT::type($obj), 'TOBJECT');
$obj = bless({} => 'TH1D');
is(SOOT::type($obj), 'TOBJECT');

$obj = bless({} => 'Something::Else');
is(SOOT::type($obj), 'HASH');

