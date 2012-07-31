use strict;
use warnings;

package Gentoo::Perl::Distmap::RecordSet;

# ABSTRACT: A collection of Record objects representing versions in >1 repos.

use Moo;
use Sub::Quote qw( quote_sub );

has 'records' => ( is => rw =>, default => quote_sub(q{ [] }) );

sub has_versions {
  my $self = shift;
  return scalar grep { $_->has_versions } @{ $self->records };
}

sub is_multi_repo {
  my $self = shift;
  my %seen;
  for my $record ( grep { $_->has_versions } @{ $self->records } ) {
    $seen{ $record->repository }++;
  }
  return 1 if scalar keys %seen > 1;
  return;
}

sub in_repo {
  my ( $self, $repository ) = @_;
  return grep { $_->repository eq $repository }
    grep { $_->has_versions } @{ $self->records };
}

sub to_rec {
  my ($self) = @_;
  return [ map { $_->to_rec } @{ $self->records } ];
}

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
__PACKAGE__->meta->make_immutable;
no Moose;

1;
