use strict;
use warnings;

package Gentoo::Perl::Distmap::RecordSet;

# ABSTRACT: A collection of Record objects representing versions in >1 repositories.

use Moose;

with 'Gentoo::Perl::Distmap::Role::Serialize';

=attr records

=attr_method records -> records

=attr_method all_records -> records.elements

=attr_method grep_reords -> records.grep

=cut

has 'records' => (
  isa     => ArrayRef =>,
  is      => ro       =>,
  lazy    => 1,
  traits  => ['Array'],
  default => sub      { [] },
  handles => {
    all_records  => 'elements',
    grep_records => 'grep',
  },
);

=method records_with_versions

=cut

sub records_with_versions {
  return $_[0]->grep_records( sub { $_->has_versions } );
}

=method has_versions

	if( $instance->has_versions() ) {

	}

=cut

sub has_versions {
  my $self = shift;
  return scalar $self->records_with_versions;
}

=method is_multi_repository

	if ( $instance->is_multi_repository() ){

	}

=cut

sub is_multi_repository {
  my $self = shift;
  my %seen;
  for my $record ( $self->records_with_versions ) {
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
  return grep { $_->repository eq $repository } $self->records_with_versions;
}

=method find_or_create_record

    my $record = $recordset->find_or_create_record(
        category   => foo  =>,
        package    => bar  =>,
        repository => quux =>,
    );

=cut

sub find_or_create_record {
  my ( $self, %config ) = @_;
  my %cloned;
  for my $need (qw( category package repository )) {
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
  my (@found) = $self->grep_records(
    sub {
      return unless $_->category eq $cloned{category};
      return unless $_->package eq $cloned{package};
      return unless $_->repository eq $cloned{repository};
      1;
    }
  );
  return $found[0] if scalar @found == 1;
  if ( scalar @found > 1 ) {
    require Carp;
    Carp::confess( sprintf 'Bug: >1 result for ==category(%s) ==package(%s) ==repository(%s) ',
      $cloned{category}, $cloned{package}, $cloned{repository} );
  }
  require Gentoo::Perl::Distmap::Record;
  ## no critic( ProhibitAmbiguousNames )
  my $record = Gentoo::Perl::Distmap::Record->new(
    category   => $cloned{category},
    package    => $cloned{package},
    repository => $cloned{repository},
  );
  push @{ $self->records }, $record;
  return $record;

}

=method add_version

	$instance->add_version(
		category   => 'gentoo-category',
		package    => 'gentoo-package',
		version    => 'gentoo-version',
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
  my $record = $self->find_or_create_record(
    category   => $cloned{category},
    package    => $cloned{package},
    repository => $cloned{repository},
  );
  if ( scalar grep { $_ eq $cloned{version} } @{ $record->versions_gentoo } ) {
    require Carp;
    Carp::carp( "Tried to insert version $cloned{version} muliple times for "
        . " package $cloned{package} category $cloned{category} repository $cloned{repository}" );
    return;
  }
  $record->add_version( $cloned{version} );
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

__PACKAGE__->meta->make_immutable;
no Moose;

1;
