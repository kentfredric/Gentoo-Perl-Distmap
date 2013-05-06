use strict;
use warnings;

package Gentoo::Perl::Distmap::Record;

# ABSTRACT: A Single C<Distmap> Record

use Moose;

with 'Gentoo::Perl::Distmap::Role::Serialize';

=head1 SYNOPSIS

    record: {
        category:
        package:
        repository:
        versions_gentoo: [

        ]
    }

    my $record = Gentoo::Perl::Distmap::Record->new(
        category => 'dev-perl',
        package  => 'Moo',
        repository => 'perl-experimental',
    );

    $record->description # dev-perl/Moo::perl-experimental

    $record->has_versions() # undef

    $record->describe_version( '1.1') #     '=dev-perl/Moo-1.1::perl-experimental'

    $record->add_version('1.1');

    my ( @packages ) = $record->enumerate_packages();

    @packages = (
        '=dev-perl/Moo-1.1::perl-experimental'
    )

=attr category

=attr_method category -> category

=attr package

=attr_method package -> package

=attr repository

=attr_method repository -> repository

=attr versions_gentoo

=attr_method versions_gentoo -> versions_gentoo

=attr_method add_version -> versions_gentoo.push

	$instance->add_version('1.1');

=attr_method has_versions -> versions_gentoo.count

	if( $instance->has_versions ){

	}

=cut

has 'category'   => ( isa => Str =>, is => ro =>, required => 1 );
has 'package'    => ( isa => Str =>, is => ro =>, required => 1 );
has 'repository' => ( isa => Str =>, is => ro =>, required => 1 );
has 'versions_gentoo' => (
  isa     => 'ArrayRef[Str]',
  is      => ro =>,
  lazy    => 1,
  default => sub { [] },
  traits  => ['Array'],
  handles => {
    add_version  => 'push',
    has_versions => 'count',
  },
);

=method description

A pretty description of this object

    say $object->description
    # dev-perl/Foo::gentoo

=cut

sub description {
  my ($self) = @_;
  return sprintf '%s/%s::%s', $self->category, $self->package, $self->repository;
}

=method describe_version

Like L</description> but for a specified version

    say $object->describe_version('1.1');
    # =dev-perl/Foo-1.1::gentoo

=cut

sub describe_version {
  my ( $self, $version ) = @_;
  return sprintf '=%s/%s-%s::%s', $self->category, $self->package, $version, $self->repository;
}

=method enumerate_packages

Returns package declarations for all versions

	my @packages = $instance->enumerate_packages();

    # =dev-perl/Foo-1.1::gentoo
    # =dev-perl/Foo-1.2::gentoo

=cut

sub enumerate_packages {
  my ($self) = @_;
  return map { $self->describe_version($_) } $self->versions_gentoo;
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
  my $rec_clone    = { %{$rec} };
  my $construction = {};
  for my $key (qw( category package repository versions_gentoo )) {
    next unless exists $rec_clone->{$key};
    $construction->{$key} = delete $rec_clone->{$key};
  }
  if ( keys %{$rec_clone} ) {
    require Carp;
    Carp::cluck( 'Unknown keys : ' . join q{,}, keys %{$rec_clone} );
  }
  return $class->new( %{$construction} );
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;
