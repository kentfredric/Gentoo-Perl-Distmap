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

=method multi_repository_dists

	my @names = $instance->multi_repository_dists();

=cut

sub multi_repository_dists {
  my ($self) = @_;
  return grep { $self->store->{$_}->is_multi_repository } $self->all_mapped_dists;
}

=method dists_in_repository

	my @names = $instance->dists_in_repository('gentoo');

=cut

sub dists_in_repository {
  my ( $self, $repository ) = @_;
  return grep { $self->store->{$_}->in_repository($repository) } $self->all_mapped_dists;
}

=method add_version

	$instance->add_version(
		distribution => 'Perl-Dist-Name'
		category     => 'gentoo-category-name',
		package      => 'gentoo-package-name',
		version      => 'gentoo-version',
		repository   => 'gentoo-repository-name',
	);

=cut
sub add_version {
	my ( $self, %config ) = @_;
	my %cloned;
	for my $need ( qw( distribution category package version repository ) ) {
		if ( exists $config{$need} ){
			$cloned{$need} = delete $config{$need};
			next;
		}
		require Carp;
		Carp::confess("Need parameter $need in config");
	}
	if ( keys %config ){ 
		require Carp;
		Carp::confess("Suplus keys in config: " . join q[,], keys %config );
	}
	if ( not exists $self->store->{ $cloned{distribution} } ){
		$self->store->{ $cloned{distribution} } = Gentoo::Perl::Distmap::RecordSet->new();
	}
	my $distro = delete $cloned{distribution};
	$self->store->{ $distro }->add_version(%cloned);
	return $self->store->{$distro};
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
