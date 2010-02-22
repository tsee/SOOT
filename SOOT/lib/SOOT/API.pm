package SOOT::API;
use strict;
use warnings;

require SOOT;
use base 'Exporter';

our %EXPORT_TAGS = ( 'all' => [ qw(
  type cproto prevent_destruction
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

You may chose to import individual functions (see below) or
all exported functions. You can import all functions with

  use SOOT::API ':all';

=head1 FUNCTIONS

=head2 type

Tries to guess the SOOT type of its argument and returns a
string such as C<"INTEGER">.

=head2 cproto

Tries to guess the SOOT type of its argument and returns a
string such as C<"int"> or C<"TGraph">.

=head2 prevent_destruction

Manually marks a given Perl object as not responsible for freeing
the underlying ROOT object. If this is necessary, that's a bug in SOOT.
This is a natural cause of memory leaks...

=head1 OTHER API CLASSES

=head2 SOOT::API::ClassIterator

C<SOOT::API::ClassIterator> is a very simple iterator class that
lets you iterate over all wrapped ROOT class names:

  my $iter = SOOT::API::ClassIterator->new;
  while (defined(my $class = $iter->next)) {
    # use $class
  }

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

