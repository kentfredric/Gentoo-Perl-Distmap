use strict;
use warnings;

package Gentoo::Perl::Distmap::RecordSet;

# ABSTRACT: A collection of Record objects representing versions in >1 repos.

use Moo;
use MooseX::Has::Sugar qw( rw );
use Sub::Quote qw( quote_sub );

with 'Gentoo::Perl::Distmap::Role::Serialize';

=attr records

=attr_method records -> records

=cut

has 'records' => rw, default => quote_sub(q{ [] });

=method has_versions

	if( $instance->has_versions() ) {

	}

=cut

sub has_versions {
  my $self = shift;
  return scalar grep { $_->has_versions } @{ $self->records };
}

=method is_multi_repository

	if ( $instance->is_multi_repository() ){

	}

=cut

sub is_multi_repository {
  my $self = shift;
  my %seen;
  for my $record ( grep { $_->has_versions } @{ $self->records } ) {
    $seen{ $record->repository }++;
  }
  return 1 if scalar keys %seen > 1;
  return;
}

=method in_repository

	if ( my @records = $instance->in_repository('gentoo') ) {
		/* records from gentoo only */
	}

=cut

sub in_repository {
  my ( $self, $repository ) = @_;
  return grep { $_->repository eq $repository }
    grep      { $_->has_versions } @{ $self->records };
}

=method add_version

	$instance->add_version(
		category => 'gentoo-category',
		package  => 'gentoo-package',
		version  => 'gentoo-version',
		repository => 'gentoo-repository',
	);
=cut

sub add_version {
  my ( $self, %config ) = @_;
  my %cloned;
  for my $need (qw( category package version repository )) {
    if ( exists $config{$need} ) {
      $cloned{$need} = delete $config{$need};
      next;
    }
    require Carp;
    Carp::confess("Need parameter $need in config");
  }
  if ( keys %config ) {
    require Carp;
    Carp::confess( 'Surplus keys in config: ' . join q[,], keys %config );
  }
  ## no critic( ProhibitAmbiguousNames )
  my $record;
  my (@found) = $self->in_repository( $cloned{repository} );
  @found =
    grep { $_->category eq $cloned{category} and $_->package eq $cloned{package} } @found;
  if ( @found == 1 ) {
    $record = $found[0];
  }
  elsif ( @found > 1 ) {
    require Carp;
    Carp::confess( sprintf 'Bug: >1 result for ==category(%s) ==package(%s) ==repository(%s) ',
      $cloned{category}, $cloned{package}, $cloned{repository} );
  }
  else {
    require Gentoo::Perl::Distmap::Record;
    $record = Gentoo::Perl::Distmap::Record->new(
      category   => $cloned{category},
      package    => $cloned{package},
      repository => $cloned{repository},
    );
    push @{ $self->records }, $record;
  }
  if ( scalar grep { $_ eq $cloned{version} } @{ $record->versions_gentoo } ) {
    require Carp;
    Carp::carp( "Tried to insert version $cloned{version} muliple times for "
        . " package $cloned{package} category $cloned{category} repository $cloned{repository}" );
    return;
  }
  push @{ $record->versions_gentoo }, $cloned{version};
  return;

}

=method to_rec

	my $datastructure = $instance->to_rec

=cut

sub to_rec {
  my ($self) = @_;
  return [ map { $_->to_rec } @{ $self->records } ];
}

=classmethod from_rec

	my $instance = G:P:D:RecordSet->from_rec( $datastructure );

=cut

sub from_rec {
  my ( $class, $rec ) = @_;
  if ( ref $rec ne 'ARRAY' ) {
    require Carp;
    Carp::confess('Can only convert from ARRAY records');
  }
  my $rec_clone = [ @{$rec} ];
  require Gentoo::Perl::Distmap::Record;
  return $class->new( records => [ map { Gentoo::Perl::Distmap::Record->from_rec($_) } @{$rec_clone} ] );
}

no Moo;
no MooseX::Has::Sugar;

1;
