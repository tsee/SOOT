package SOOT::API;
use strict;
use warnings;

require SOOT;
use base 'Exporter';

our %EXPORT_TAGS = ( 'all' => [ qw(
  type cproto
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );
our @EXPORT;

1;
__END__

=head1 NAME

SOOT::API - Perl interface to Perl-ROOT wrapper internals

=head1 SYNOPSIS

  use SOOT::API qw(type cproto);
  my $cproto = cproto("blah");
  print "$cproto\n"; # prints 'char*'

=head1 DESCRIPTION

This package exposes some of the internals of the Perl-ROOT
wrapper to Perl. All functions are to be considered experimental
and subject to change. If you need a stable API, contact the author(s).

=head2 EXPORT

None by default.

You may chose to import individual functions (see synopsis) or
all exported functions. You can import all functions with

  use SOOT::API ':all';

=head1 SEE ALSO

L<SOOT>

L<http://root.cern.ch>

=head1 AUTHOR

Steffen Mueller, E<lt>smueller@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 by Steffen Mueller

SOOT, the Perl-ROOT wrapper, is free software; you can redistribute it and/or modify
it under the same terms as ROOT itself, that is, the GNU Lesser General Public License.
A copy of the full license text is available from the distribution as the F<LICENSE> file.

=cut

