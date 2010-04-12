package Alien::ROOT;
use 5.008;
use strict;
use warnings;
use Carp ();

=head1 NAME

Alien::ROOT - Utility package to install and locate CERN's ROOT library

=cut

our $VERSION = '1.000';
$VERSION = eval $VERSION;

=head1 SYNOPSIS

  use Alien::ROOT;

  my $aroot = Alien::ROOT->new;

=head1 DESCRIPTION



=head1 METHODS

=head2 Alien::ROOT->new

Creates a new C<Alien::ROOT> object, which essentially just has a few
convenience methods providing useful information like the path
to the ROOT installation (C<ROOTSYS> environment variable)
and the path to the F<root-config> utility.

=cut

sub new {
  my $class = shift;

  Carp::croak('You must call this as a class method') if ref($class);

  my $self = {
    installed   => 0,
    root_config => undef,
    version     => undef,
    cflags      => undef,
    ldflags     => undef,
    features    => undef,
  };

  bless($self, $class);

  $self->_load_modules();
  $self->_configure();

  return $self;
}

sub _load_modules {
  require File::Spec;
  require Config;
  require ExtUtils::MakeMaker;
  require Capture::Tiny;
}

=head2 $aroot->installed

Determine if a valid installation of ROOT has been detected in the system.
This method will return a true value if it is, or undef otherwise.

Example code:

  print "okay\n" if $aroot->installed;

=cut

sub installed {
  my $self = shift;

  Carp::croak('You must call this method as an object') unless ref($self);

  return $self->{installed};
}

=head2 $aroot->version

Determine the installed version of ROOT, as a string.

Example code:

  my $version = $aroot->version;

=cut

sub version {
  my ($self) = @_;

  Carp::croak('You must call this method as an object') unless ref($self);

  return $self->_config_get_one_line_param('version', '--version');
}

=head2 $aroot->ldflags

=head2 $aroot->linker_flags

This returns the flags required to link C code with the local installation of
ROOT.

Example code:

  my $ldflags = $aroot->ldflags;

=cut

sub ldflags {
  my $self = shift;

  Carp::croak('You must call this method as an object') unless ref($self);

  return $self->_config_get_one_line_param('ldflags', qw(--ldflags --glibs --auxlibs));
}

# Glob to create an alias to ldflags
*linker_flags = *ldflags;

=head2 $aroot->cflags

=head2 $aroot->compiler_flags

This method returns the compiler option flags to compile C++ code which uses
the ROOT library (typically in the CFLAGS variable).

Example code:

  my $cflags = $aroot->cflags;

=cut

sub cflags {
  my $self = shift;

  Carp::croak('You must call this method as an object') unless ref($self);

  return $self->_config_get_one_line_param('cflags', qw(--cflags --auxcflags));
}
*compiler_flags = *cflags;

=head2 $aroot->features

This method returns a string of ROOT features that were enabled when ROOT
was compiled.

Example code:

  my $features = $aroot->features;
  if ($features !~ /\bexplicitlink\b/) {
    warn "ROOT was built without the --explicitlink option";
  }

=cut

sub features {
  my $self = shift;

  Carp::croak('You must call this method as an object') unless ref($self);

  return $self->_config_get_one_line_param('features', qw(--features));
}


# Private methods to find & fill out information

sub _configure {
  my $self = shift;
  
  my $root_config;
  if (defined $ENV{ROOTSYS}) {
    $root_config = File::Spec->catfile($ENV{ROOTSYS}, 'bin', 'root-config');
    $root_config = undef if not -x $root_config;
  }
  else {
    $root_config = $self->_can_run('root-config');
  }
    
  if (not defined $root_config) {
    return();
  }
  $self->{root_config} = $root_config;
  $self->{installed} = 1;
}

# From Module::Install::Can
# check if we can run some command
sub _can_run {
  my ($self, $cmd) = @_;

  my $_cmd = $cmd;
  return $_cmd if (-x $_cmd or $_cmd = MM->maybe_command($_cmd));

  for my $dir ((split /$Config::Config{path_sep}/, $ENV{PATH}), '.') {
    next if $dir eq '';
    my $abs = File::Spec->catfile($dir, $_[1]);
    return $abs if (-x $abs or $abs = MM->maybe_command($abs));
  }

  return;
}

sub _config_run_stdio {
  my $self = shift;
  my @args = @_;
  return() if not defined $self->{root_config};
  my $output = Capture::Tiny::capture_merged(sub {
    system($self->{root_config}, @args);
  });
  return $output;
}

sub _config_get_one_line_param {
  my $self = shift;
  my $param = shift;
  my @opts = @_;

  return() if not $self->installed;
  return $self->{$param} if defined $self->{$param};

  my $out = $self->_config_run_stdio(@opts) || '';
  $self->{$param} = (split /\n/, $out, 2)[0];
  return $self->{$param};
}


1;

__END__

=head1 AUTHOR

Steffen Mueller E<lt>smueller@cpan.orgE<gt>

=head1 ACKNOWLEDGMENTS

This package is based upon Jonathan Yu's L<Alien::libjio>
which he kindly allowed me to use as a starting point.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Alien::ROOT

You can also look for information at:

=over

=item * Search CPAN

L<http://search.cpan.org/dist/Alien-ROOT>

=item * CPAN Request Tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Alien-ROOT>

=item * CPAN Testers Platform Compatibility Matrix

L<http://cpantesters.org/show/Alien-ROOT.html>

=back

=head1 REPOSITORY

You can access the most recent development version of this module at:

L<git://github.com/tsee/ROOT.git>

=head1 SEE ALSO

L<SOOT>, the Perl-ROOT wrapper.

L<SOOT::App>, the SOOT shell.

L<Alien>, the Alien manifesto.

=head1 LICENSE

This module is licensed under the GNU General Public License 2.0
or at your discretion, any newer version of the GPL. You can
find a copy of the license in the F<LICENSE> file of this package
or at L<http://www.opensource.org/licenses/gpl-2.0.php>

=cut

