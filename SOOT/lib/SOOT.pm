package SOOT;
use 5.008001;
use strict;
use warnings;

our $VERSION = '0.01';

use base 'Exporter';
require TObject;
require TArray;

require XSLoader;
XSLoader::load('SOOT', $VERSION);

use vars qw/$gApplication $gSystem $gRandom/;
our %EXPORT_TAGS = ( 'all' => [ qw(
  $gApplication $gSystem $gRandom
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );
our @EXPORT;

1;
__END__

=head1 NAME

SOOT - Use ROOT from Perl

=head1 SYNOPSIS

  use SOOT;
  # more to follow

=head1 DESCRIPTION

SOOT is a Perl extension for using the ROOT library. It is very similar
to the Ruby-ROOT or PyROOT extensions for their respective languages.
Specifically, SOOT was implemented after the model of Ruby-ROOT.

Please note that SOOT is to be considered highly experimental at this point.
It uses a very dynamic approach to wrapping a very large and quickly
evolving library. Due to the dynamic nature (using the CInt introspection),
SOOT is able to handle most of the ROOT classes without explicitly
wrapping them. Some things are expected to not work because not enough
information about the API can be obtained automatically. Let me know
what you need and what is giving you problems and we'll work out a solution.

In order to install and use SOOT, you need a configured ROOT library.
In particular, it is necessary that the F<root-config> tool be executable
and findable via your C<PATH> environment variable. Alternatively, you
may set the C<ROOTSYS> environment variable. Please refer to the ROOT
manual for details.

=head1 SEE ALSO

L<http://root.cern.ch>

L<SOOT::API>

=head1 AUTHOR

Steffen Mueller, E<lt>smueller@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 by Steffen Mueller

SOOT, the Perl-ROOT wrapper, is free software; you can redistribute it and/or modify
it under the same terms as ROOT itself, that is, the GNU Lesser General Public License.
A copy of the full license text is available from the distribution as the F<LICENSE> file.

=cut

