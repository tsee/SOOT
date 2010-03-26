package ExtUtils::XSpp::Exception::message;
use strict;
use warnings;
use base 'ExtUtils::XSpp::Exception';

sub _dl { return defined( $_[0] ) && length( $_[0] ) ? $_[0] : undef }

sub init {
  my $this = shift;
  $this->SUPER::init(@_);
  my %args = @_;

  $this->{CALL_FUNCTION_CODE} = _dl( $args{call_function_code} || $args{arg1} );
}

sub handler_code {
  my $this = shift;
  my $no_spaces_indent = shift;
  $no_spaces_indent = 4 if not defined $no_spaces_indent;

  my $ctype = $this->cpp_type;
  my $msg = "Caught C++ exception of type or derived from '$ctype': \%s";
  my $code = <<HERE;
catch ($ctype& e) {
  croak("$msg", e.what());
}
HERE
  return $this->indent_code($code, $no_spaces_indent);
}

1;
