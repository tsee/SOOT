package Alien::ROOT::Builder::Utility;

# This is essentially taken from Alien::wxWidgets

use strict;
use base qw(Exporter);
use Config;
use Fatal qw(open);

our @EXPORT_OK = qw(aroot_arch_file aroot_install_arch_file
                    aroot_install_arch_auto_file
                    aroot_arch_dir aroot_install_arch_dir aroot_touch);

sub aroot_arch_file {
  my( $vol, $dir, $file ) = File::Spec->splitpath( $_[0] || '' );
  File::Spec->catfile( 'blib', 'arch', 'Alien', 'ROOT',
                       File::Spec->splitdir( $dir ), $file );
}

sub aroot_arch_dir {
  my( $vol, $dir, $file ) = File::Spec->splitpath( $_[0] || '' );
  File::Spec->catdir( 'blib', 'arch', 'Alien', 'ROOT',
                      File::Spec->splitdir( $dir ), $file );
}

sub aroot_install_arch_file {
  my( $build, $p ) = @_;
  my( $vol, $dir, $file ) = File::Spec->splitpath( $p || '' );
  File::Spec->catfile( $build->install_destination( 'arch' ), 'Alien', 'ROOT',
                       File::Spec->splitdir( $dir ), $file );
}

sub aroot_install_arch_dir {
  my( $build, $p ) = @_;
  my( $vol, $dir, $file ) = File::Spec->splitpath( $p || '' );
  File::Spec->catdir( $build->install_destination( 'arch' ), 'Alien', 'ROOT',
                      File::Spec->splitdir( $dir ), $file );
}

sub aroot_install_arch_auto_file {
  my( $build, $p ) = @_;
  my( $vol, $dir, $file ) = File::Spec->splitpath( $p || '' );
  File::Spec->catfile( $build->install_destination( 'arch' ), 'auto', 'Alien', 'ROOT',
                       File::Spec->splitdir( $dir ), $file );
}

sub aroot_touch {
    require ExtUtils::Command;
    local @ARGV = @_;
    ExtUtils::Command::touch();
}

1;
