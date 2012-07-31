use strict;
use warnings;

package Gentoo::Perl::Distmap::Map;
BEGIN {
  $Gentoo::Perl::Distmap::Map::AUTHORITY = 'cpan:KENTNL';
}
{
  $Gentoo::Perl::Distmap::Map::VERSION = '0.1.1';
}

# ABSTRACT: A collection of CPAN dists mapped to Gentoo ones.

use Moo;
use MooseX::Has::Sugar qw( rw );
use Sub::Quote qw( quote_sub );


has store => rw, default => quote_sub(q{ {} });


sub all_mapped_dists { return keys %{ $_[0]->store } }


sub mapped_dists {
  my ($self) = @_;
  return grep { $self->store->{$_}->has_versions } $self->all_mapped_dists;
}


sub multi_repository_dists {
  my ($self) = @_;
  return grep { $self->store->{$_}->is_multi_repository } $self->all_mapped_dists;
}


sub dists_in_repository {
  my ( $self, $repository ) = @_;
  return grep { $self->store->{$_}->in_repository($repository) } $self->all_mapped_dists;
}


sub add_version {
  my ( $self, %config ) = @_;
  my %cloned;
  for my $need (qw( distribution category package version repository )) {
    if ( exists $config{$need} ) {
      $cloned{$need} = delete $config{$need};
      next;
    }
    require Carp;
    Carp::confess("Need parameter $need in config");
  }
  if ( keys %config ) {
    require Carp;
    Carp::confess( "Suplus keys in config: " . join q[,], keys %config );
  }
  if ( not exists $self->store->{ $cloned{distribution} } ) {
    $self->store->{ $cloned{distribution} } = Gentoo::Perl::Distmap::RecordSet->new();
  }
  my $distro = delete $cloned{distribution};
  $self->store->{$distro}->add_version(%cloned);
  return $self->store->{$distro};
}


sub to_rec {
  my ($self) = @_;
  my $out;
  for my $dist ( keys %{ $self->store } ) {
    $out->{$dist} = $self->store->{$dist}->to_rec;
  }
  return $out;
}


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

__END__
=pod

=encoding utf-8

=head1 NAME

Gentoo::Perl::Distmap::Map - A collection of CPAN dists mapped to Gentoo ones.

=head1 VERSION

version 0.1.1

=head1 ATTRIBUTES

=head2 store

=head1 METHODS

=head2 all_mapped_dists

	my @names = $instance->all_mapped_dists();

=head2 mapped_dists

	my @names = $instance->mapped_dists();

=head2 multi_repository_dists

	my @names = $instance->multi_repository_dists();

=head2 dists_in_repository

	my @names = $instance->dists_in_repository('gentoo');

=head2 add_version

	$instance->add_version(
		distribution => 'Perl-Dist-Name'
		category     => 'gentoo-category-name',
		package      => 'gentoo-package-name',
		version      => 'gentoo-version',
		repository   => 'gentoo-repository-name',
	);

=head2 to_rec

	my $datastructure = $instance->to_rec

=head1 CLASS METHODS

=head2 from_rec

	my $instance = G:P:D:Map->from_rec( $datastructure );

=head1 ATTRIBUTE METHODS

=head2 store -> store

=head1 AUTHOR

Kent Fredric <kentfredric@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by Kent Fredric <kentfredric@gmail.com>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

