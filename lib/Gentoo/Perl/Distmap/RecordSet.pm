use strict;
use warnings;

package Gentoo::Perl::Distmap::RecordSet;

# ABSTRACT: A collection of Record objects representing versions in >1 repos.

use Moo;
use MooseX::Has::Sugar qw( rw );
use Sub::Quote qw( quote_sub );

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

=method is_multi_repo

	if ( $instance->is_multi_repo() ){

	}

=cut

sub is_multi_repo {
  my $self = shift;
  my %seen;
  for my $record ( grep { $_->has_versions } @{ $self->records } ) {
    $seen{ $record->repository }++;
  }
  return 1 if scalar keys %seen > 1;
  return;
}

=method in_repo

	if ( my @records = $instance->in_repo('gentoo') ) {
		/* records from gentoo only */
	}

=cut

sub in_repo {
  my ( $self, $repository ) = @_;
  return grep { $_->repository eq $repository }
    grep { $_->has_versions } @{ $self->records };
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
