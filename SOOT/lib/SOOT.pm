package SOOT;
use 5.008001;
use strict;
use warnings;
use Carp 'croak';

our $VERSION = '0.03';

use base 'Exporter';
use SOOT::Constants;
use TObject; # needs to happen before XSLoader
use TArray;

our %EXPORT_TAGS = (
  'globals' => [ qw(
    $gApplication $gSystem $gRandom $gROOT
    $gDirectory $gStyle $gPad $gBenchmark
  ) ],
  'constants' => \@SOOT::Constants::Names,
);
use vars @{$EXPORT_TAGS{globals}};

our @EXPORT_OK = map {@$_} values %EXPORT_TAGS;
$EXPORT_TAGS{all} = \@EXPORT_OK;

our @EXPORT;

require XSLoader;
XSLoader::load('SOOT', $VERSION);

_bootstrap_AUTOLOAD(); # FIXME move to XS...

sub UNIVERSAL::AUTOLOAD {
  our $AUTOLOAD;
  Carp::cluck("AUTOLOAD CALLED");
  return if not defined $AUTOLOAD;
  warn "!!!".$AUTOLOAD;
  $AUTOLOAD =~ s/::([^:]+)$//;
  my $meth = $1;
  my $class = $AUTOLOAD;
  my $ancestors = SOOT::GenerateROOTClass($class); # returns an array ref of ancestors on success
  my $exists = ! ! $ancestors;
  if (not $exists) {
    return if $meth eq 'DESTROY';
    Carp::croak("Can't locate object method \"$meth\" via package \"$class\"");
  }
  else {
    # generate AUTOLOAD for the class and all of its previously undefined ancestors
    no strict 'refs';
    foreach my $classname ($class, @$ancestors) {
      if ($classname->isa('TObject')) {
        *{"${class}::AUTOLOAD"} = \&TObject::AUTOLOAD;
      } elsif ($classname->isa('TArray')) {
        *{"${class}::AUTOLOAD"} = \&TArray::AUTOLOAD;
      }
    }
    return SOOT::CallMethod($class, $meth, \@_);
  }
}

sub AUTOLOAD {
    # This AUTOLOAD is used to 'autoload' constants from the constant()
    # XS function.

    my $constname;
    our $AUTOLOAD;
    ($constname = $AUTOLOAD) =~ s/.*:://;
    croak "&SOOT::constant not defined" if $constname eq 'constant';
    my ($error, $val) = constant($constname);
    if ($error) { croak $error; }
    {
        no strict 'refs';
        # Fixed between 5.005_53 and 5.005_61
#XXX    if ($] >= 5.00561) {
#XXX        *$AUTOLOAD = sub () { $val };
#XXX    }
#XXX    else {
            *$AUTOLOAD = sub { $val };
#XXX    }
    }
    goto &$AUTOLOAD;
}

sub _bootstrap_AUTOLOAD {
  my $classIter = SOOT::API::ClassIterator->new;
  no strict 'refs';
  while (defined(my $class = $classIter->next)) {
    # they have their own AUTOLOAD
    next if $class eq 'TObject' or $class eq 'TArray';
    if ($class->isa('TObject')) {
      *{"${class}::AUTOLOAD"} = \&TObject::AUTOLOAD;
    } elsif ($class->isa('TArray')) {
      *{"${class}::AUTOLOAD"} = \&TArray::AUTOLOAD;
    }
  }
}

# For some reason, the normal gBenchmark from XS will segfault on first use.
# Thus we initialize it here...
use vars '$gBenchmark';
$gBenchmark = TBenchmark->new;


1;
__END__

=head1 NAME

SOOT - Use ROOT from Perl

=head1 SYNOPSIS

  use SOOT ':all';
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

=head2 Exports

By default, using SOOT does not export anything into your namespace.
You may choose to import the various ROOT-related global variables
and/or constants into your namespace either by explicitly listing them
as arguments to C<use SOOT> or by importing the C<:globals>,
C<:constants>, or C<:all> tags:

  use SOOT ':all';
  # you now have $gApplication, $gSystem, kWhite etc

  use SOOT qw($gApplication $gSystem);
  # you now have only $gApplication and $gSystem
  # you always have $SOOT::gApplication, etc!

  use SOOT qw(kRed kDotted);
  my $graph = TGraph->new(3);
  $graph->SetLineColor(kRed);
  $graph->SetLineStyle(kDotted);

The list of currently supported globals is:

  $gApplication $gSystem $gRandom $gROOT
  $gDirectory   $gStyle  $gPad    $gBenchmark

=head1 SEE ALSO

L<http://root.cern.ch>

L<SOOT::API> exposes some of the underlying SOOT-internals.

L<SOOT::App> implements a F<root.exe>/CInt-like front-end
using L<Devel::REPL>. It is not part of SOOT and is available
separately from CPAN.

=head1 AUTHOR

Steffen Mueller, E<lt>smueller@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 by Steffen Mueller

SOOT, the Perl-ROOT wrapper, is free software; you can redistribute it and/or modify
it under the same terms as ROOT itself, that is, the GNU Lesser General Public License.
A copy of the full license text is available from the distribution as the F<LICENSE> file.

=cut

