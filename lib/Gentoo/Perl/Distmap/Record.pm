use strict;
use warnings;

package Gentoo::Perl::Distmap::Record;

# ABSTRACT: A Single Distmap Record

use Moo;
use MooseX::Has::Sugar qw( rw required );

=attr category

=attr_method category -> category

=attr package

=attr_method package -> package

=attr repository

=attr_method repository -> repository

=attr versions_gentoo

=attr_method versions_gentoo -> versions_gentoo

=cut

has 'category'        => rw, required;
has 'package'         => rw, required;
has 'repository'      => rw, required;
has 'versions_gentoo' => rw, required;

=method add_version

	$instance->add_version('1.1');

=cut

sub add_version {
  my ( $self, @versions ) = @_;
  push @{ $self->versions_gentoo }, @versions;
  return $self;
}

=method has_versions

	if( $instance->has_versions ){

	}

=cut

sub has_versions {
  return scalar @{ $_[0]->versions_gentoo };
}

=method enumerate_packages

	my @packages = $instance->enumerate_packages();

=cut

sub enumerate_packages {
  my ($self) = @_;
  my @out;
  my $prefix = sprintf '=%s/%s-', $self->category, $self->package;
  my $suffix = sprintf '::%s', $self->repository;
  for my $version ( @{ $self->versions_gentoo } ) {
    push @out, $prefix . $version . $suffix;
  }
  return @out;
}

=method to_rec

	my $datastructure = $instance->to_rec

=cut 

sub to_rec {
  my ($self) = @_;
  return {
    category        => $self->category,
    package         => $self->package,
    repository      => $self->repository,
    versions_gentoo => $self->versions_gentoo,
  };
}

=classmethod from_rec

	my $instance = G:P:D:Record->from_rec( $datastructure );

=cut

sub from_rec {
  my ( $class, $rec ) = @_;
  if ( ref $rec ne 'HASH' ) {
    require Carp;
    Carp::confess('Can only convert from hash records');
  }
  my $rec_clone = { %{$rec} };
  my $instance  = $class->new(
    category        => delete $rec_clone->{category},
    package         => delete $rec_clone->{package},
    repository      => delete $rec_clone->{repository},
    versions_gentoo => delete $rec_clone->{versions_gentoo},
  );
  if ( keys %{$rec_clone} ) {
    require Carp;
    Carp::cluck( 'Unknown keys : ' . join q{,}, keys %{$rec_clone} );
  }
  return $instance;
}

no Moo;
no MooseX::Has::Sugar;

1;
