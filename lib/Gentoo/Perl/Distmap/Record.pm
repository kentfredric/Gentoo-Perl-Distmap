use strict;
use warnings;

package Gentoo::Perl::Distmap::Record;
BEGIN {
  $Gentoo::Perl::Distmap::Record::AUTHORITY = 'cpan:KENTNL';
}
{
  $Gentoo::Perl::Distmap::Record::VERSION = '0.1.3';
}

# ABSTRACT: A Single Distmap Record

use Moo;
use MooseX::Has::Sugar qw( rw required );
use Sub::Quote qw( quote_sub );

with 'Gentoo::Perl::Distmap::Role::Serialize';


has 'category'        => rw, required;
has 'package'         => rw, required;
has 'repository'      => rw, required;
has 'versions_gentoo' => rw, default => quote_sub(q|[]|);


sub add_version {
  my ( $self, @versions ) = @_;
  push @{ $self->versions_gentoo }, @versions;
  return $self;
}


sub has_versions {
  return scalar @{ $_[0]->versions_gentoo };
}


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


sub to_rec {
  my ($self) = @_;
  return {
    category        => $self->category,
    package         => $self->package,
    repository      => $self->repository,
    versions_gentoo => $self->versions_gentoo,
  };
}


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

__END__
=pod

=encoding utf-8

=head1 NAME

Gentoo::Perl::Distmap::Record - A Single Distmap Record

=head1 VERSION

version 0.1.3

=head1 ATTRIBUTES

=head2 category

=head2 package

=head2 repository

=head2 versions_gentoo

=head1 METHODS

=head2 add_version

	$instance->add_version('1.1');

=head2 has_versions

	if( $instance->has_versions ){

	}

=head2 enumerate_packages

	my @packages = $instance->enumerate_packages();

=head2 to_rec

	my $datastructure = $instance->to_rec

=head1 CLASS METHODS

=head2 from_rec

	my $instance = G:P:D:Record->from_rec( $datastructure );

=head1 ATTRIBUTE METHODS

=head2 category -> category

=head2 package -> package

=head2 repository -> repository

=head2 versions_gentoo -> versions_gentoo

=head1 AUTHOR

Kent Fredric <kentfredric@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by Kent Fredric <kentfredric@gmail.com>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

