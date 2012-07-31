use strict;
use warnings;

package Gentoo::Perl::Distmap::Map;

# ABSTRACT: A collection of CPAN dists mapped to Gentoo ones.

use Moo;
use MooseX::Has::Sugar qw( rw );
use Sub::Quote qw( quote_sub );

=attr store

=attr_method store -> store

=cut

has store => rw, default => quote_sub(q{ {} });

=method all_mapped_dists

	my @names = $instance->all_mapped_dists();

=cut

sub all_mapped_dists { return keys %{ $_[0]->store } }

=method mapped_dists
	
	my @names = $instance->mapped_dists();

=cut

sub mapped_dists {
  my ($self) = @_;
  return grep { $self->store->{$_}->has_versions } $self->all_mapped_dists;
}

=method multi_repo_dists

	my @names = $instance->multi_repo_dists();

=cut

sub multi_repo_dists {
  my ($self) = @_;
  return grep { $self->store->{$_}->is_multi_repo } $self->all_mapped_dists;
}

=method dists_in_repo

	my @names = $instance->dists_in_repo('gentoo');

=cut

sub dists_in_repo {
  my ( $self, $repo ) = @_;
  return grep { $self->store->{$_}->in_repo($repo) } $self->all_mapped_dists;
}

=method to_rec

	my $datastructure = $instance->to_rec

=cut

sub to_rec {
  my ($self) = @_;
  my $out;
  for my $dist ( keys %{ $self->store } ) {
    $out->{$dist} = $self->store->{$dist}->to_rec;
  }
  return $out;
}

=classmethod from_rec

	my $instance = G:P:D:Map->from_rec( $datastructure );

=cut

sub from_rec {
  my ( $class, $rec ) = @_;
  if ( ref $rec ne 'HASH' ) {
    require Carp;
    Carp::confess('Can only convert from hash records');
  }
  my $rec_clone = { %{$rec} };
  my $in;
  require Gentoo::Perl::Distmap::RecordSet;
  for my $dist ( keys %{$rec_clone} ) {
    $in->{$dist} = Gentoo::Perl::Distmap::RecordSet->from_rec( $rec_clone->{$dist} );
  }
  return $class->new( store => $in, );
}

no Moo;
no MooseX::Has::Sugar;

1;
