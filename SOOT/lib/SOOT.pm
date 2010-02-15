package SOOT;
use 5.010000;
use strict;
use warnings;

our $VERSION = '0.01';

require TObject;
require TArray;

require XSLoader;
XSLoader::load('SOOT', $VERSION);

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

