use strict;
use warnings;
use Test::More tests => 24;
use SOOT;
pass();

is(SOOT::cproto("foo"), "char*");
is(SOOT::cproto(9), "int");
is(SOOT::cproto(9.1), "double");

my $int = 2;
my $float = 3.1;
my $str = "fooo";

is(SOOT::cproto($str), "char*");
is(SOOT::cproto($int), "int");
is(SOOT::cproto($float), "double", "float var has double prototype");

my $foo = "123";
is(SOOT::cproto($foo), "char*");

$foo = "123"+2;
is(SOOT::cproto($foo), "int");

$foo = "123.2"+2;
is(SOOT::cproto($foo), "double");

$foo = (.2*3.3)."";
is(SOOT::cproto($foo), "char*");
is(SOOT::cproto($foo*$foo), "double");

is(SOOT::cproto([]), undef);
is(SOOT::cproto({}), undef);
is(SOOT::cproto(sub {}), undef);
is(SOOT::cproto(\1), undef);
is(SOOT::cproto(\$foo), undef, "reference to scalar does not have known prototype");

my $scalar;
my $obj;
$obj = bless(\$scalar => 'TObject');
is(SOOT::cproto($obj), 'TObject*');
$obj = bless(\$scalar => 'TH1D');
is(SOOT::cproto($obj), 'TH1D*');

$obj = bless([] => 'TObject');
is(SOOT::cproto($obj), 'TObject*');
$obj = bless([] => 'TH1D');
is(SOOT::cproto($obj), 'TH1D*');


$obj = bless({} => 'TObject');
is(SOOT::cproto($obj), 'TObject*');
$obj = bless({} => 'TH1D');
is(SOOT::cproto($obj), 'TH1D*');

$obj = bless({} => 'Something::Else');
is(SOOT::cproto($obj), undef);

