package Alien::ROOT;

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
    installed => 0,
  };

  bless($self, $class);

  $self->_try_pkg_config()
    or $self->_try_liblist()
    or delete($self->{method});

  return $self;
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

Determine the installed version of libjio, as a string.

Currently versions are simply floating-point numbers, so you can treat the
version number as such, but this behaviour is subject to change.

Example code:

  my $version = $jio->version;

=cut

sub version {
  my ($self) = @_;

  Carp::croak('You must call this method as an object') unless ref($self);

  return $self->{version};
}

=head2 $jio->ldflags

=head2 $jio->linker_flags

This returns the flags required to link C code with the local installation of
libjio (typically in the LDFLAGS variable). It is particularly useful for
building and installing Perl XS modules such as L<IO::Journal>.

In scalar context, it returns an array reference suitable for passing to
other build systems, particularly L<Module::Build>. In list context, it gives
a normal array so that C<join> and friends will work as expected.

Example code:

  my $ldflags = $jio->ldflags;
  my @ldflags = @{ $jio->ldflags };
  my $ldstring = join(' ', $jio->ldflags);
  # or:
  # my $ldflags = $jio->linker_flags;

=cut

sub ldflags {
  my ($self) = @_;

  Carp::croak('You must call this method as an object') unless ref($self);

  # Return early if called in void context
  return unless defined wantarray;

  # If calling in array context, dereference and return
  return @{ $self->{ldflags} } if wantarray;

  return $self->{ldflags};
}

# Glob to create an alias to ldflags
*linker_flags = *ldflags;

=head2 $jio->cflags

=head2 $jio->compiler_flags

This method returns the compiler option flags to compile C code which uses
the libjio library (typically in the CFLAGS variable). It is particularly
useful for building and installing Perl XS modules such as L<IO::Journal>.

Example code:

  my $cflags = $jio->cflags;
  my @cflags = @{ $jio->cflags };
  my $ccstring = join(' ', $jio->cflags);
  # or:
  # my $cflags = $jio->compiler_flags;

=cut

sub cflags {
  my ($self) = @_;

  Carp::croak('You must call this method as an object') unless ref($self);

  # Return early if called in void context
  return unless defined wantarray;

  # If calling in array context, dereference and return
  return @{ $self->{cflags} } if wantarray;

  return $self->{cflags};
}
*compiler_flags = *cflags;

=head2 $jio->method

=head2 $jio->how

This method returns the method the module used to find information about
libjio. The following methods are currently used (in priority order):

=over

=item *

pkg-config: the de-facto package information tool

=item *

ExtUtils::Liblist: a utility module used by ExtUtils::MakeMaker

=back

Example code:

  if ($jio->installed) {
    print 'I found this information using: ', $jio->how, "\n";
  }

=cut

sub method {
  my ($self) = @_;

  Carp::croak('You must call this method as an object') unless ref($self);

  return $self->{method};
}
*how = *method;

# Private methods to find & fill out information

use IPC::Open3 ('open3');

sub _get_pc {
  my ($key) = @_;

  my $read;
  my $pid = open3(undef, $read, undef, 'pkg-config', 'libjio', '--' . $key);
  # We're using blocking wait, so the return value doesn't matter
  ## no critic(RequireCheckedSyscalls)
  waitpid($pid, 0);

  # Check the exit status; 0 = success - nonzero = failure
  if (($? >> 8) == 0) {
    # The value we got back
    return <$read>;
  }
  return (undef, <$read>) if wantarray;
  return;
}

sub _try_pkg_config {
  my ($self) = @_;

  my ($value, $err) = _get_pc('cflags');
  return unless (defined $value && length $value);
  #if (defined $err && length $err) {
  #  #warn "Problem with pkg-config; using ExtUtils::Liblist instead\n";
  #  return;
  #}

  $self->{installed} = 1;
  $self->{method} = 'pkg-config';

  # pkg-config returns things with a newline, so remember to remove it
  $self->{cflags} = [ split(' ', $value) ];
  $self->{ldflags} = [ split(' ', _get_pc('libs')) ];
  $self->{version} = _get_pc('modversion');

  return 1;
}

sub _try_liblist {
  my ($self) = @_;

  use ExtUtils::Liblist ();
  local $SIG{__WARN__} = sub { }; # mask warnings

  my (undef, undef, $ldflags, $ldpath) = ExtUtils::Liblist->ext('-ljio');
  return unless (defined($ldflags) && length($ldflags));

  $self->{installed} = 1;
  $self->{method} = 'ExtUtils::Liblist';

  # Empty out cflags; initialize it
  $self->{cflags} = [];

  my $read;
  my $pid = open3(undef, $read, undef, 'getconf', 'LFS_CFLAGS');

  # We're using blocking wait, so the return value doesn't matter
  ## no critic(RequireCheckedSyscalls)
  waitpid($pid, 0);

  # Check the status code
  if (($? >> 8) == 0) {
    # This only takes the first line
    push(@{ $self->{cflags} }, split(' ', <$read>));
  }
  else {
    warn 'Problem using getconf: ', <$read>, "\n";
    push(@{ $self->{cflags} },
      '-D_LARGEFILE_SOURCE',
      '-D_FILE_OFFSET_BITS=64',
    );
  }

  # Used for resolving the include path, relative to lib
  use Cwd ();
  use File::Spec ();
  push(@{ $self->{cflags} },
    # The include path is taken as: $libpath/../include
    '-I' . Cwd::realpath(File::Spec->catfile(
      $ldpath,
      File::Spec->updir(),
      'include'
    ))
  );

  push(@{ $self->{ldflags} },
    '-L' . $ldpath,
    $ldflags,
  );

  return 1;
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

