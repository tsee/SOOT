package SOOT::App;
use 5.008001;
use strict;
use warnings;

our $VERSION = '0.01';
use Capture::Tiny qw/capture/;

sub run {
  my $class = shift;
  require Devel::REPL;
  require SOOT;

  my $repl = Devel::REPL->new;
  foreach (qw(FindVariable History LexEnv)) {
    $repl->load_plugin($_)
  }
  foreach (qw(Colors Completion DDS Interrupt
              MultiLine::PPI OutputCache PPI)) {
    my @discard = capture {
      eval {
        $repl->load_plugin($_)
      }
    };
  }
  package main;
  SOOT->import(':all');
  # FIXME: mst will likely kill me for this
  $repl->formatted_eval("no strict 'vars'");
  $repl->formatted_eval("use SOOT qw/:all/");
  return $repl->run();
}


1;
__END__

=head1 NAME

SOOT::App - A Perl REPL using SOOT (ROOT)

=head1 SYNOPSIS

  use SOOT::App;
  SOOT::App->run();

=head1 DESCRIPTION

SOOT is a Perl extension for using the ROOT library. It is very similar
to the Ruby-ROOT or PyROOT extensions for their respective languages.
Specifically, SOOT was implemented after the model of Ruby-ROOT.

SOOT::App implements the equivalent of the ROOT/CInt shell for Perl
using L<Devel::REPL>.

=head1 SEE ALSO

L<http://root.cern.ch>

L<SOOT>

=head1 AUTHOR

Steffen Mueller, E<lt>smueller@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 by Steffen Mueller

SOOT, the Perl-ROOT wrapper, is free software; you can redistribute it and/or modify
it under the same terms as ROOT itself, that is, the GNU Lesser General Public License.
A copy of the full license text is available from the distribution as the F<LICENSE> file.

=cut

