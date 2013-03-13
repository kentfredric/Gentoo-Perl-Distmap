use strict;
use warnings;

package Gentoo::Perl::Distmap::RecordSet;
BEGIN {
  $Gentoo::Perl::Distmap::RecordSet::AUTHORITY = 'cpan:KENTNL';
}
{
  $Gentoo::Perl::Distmap::RecordSet::VERSION = '0.1.4';
}

# ABSTRACT: A collection of Record objects representing versions in >1 repositories.

use Moo;
use MooseX::Has::Sugar qw( rw );
use Sub::Quote qw( quote_sub );

with 'Gentoo::Perl::Distmap::Role::Serialize';


has 'records' => rw, default => quote_sub(q{ [] });


sub has_versions {
  my $self = shift;
  return scalar grep { $_->has_versions } @{ $self->records };
}


sub is_multi_repository {
  my $self = shift;
  my %seen;
  for my $record ( grep { $_->has_versions } @{ $self->records } ) {
    $seen{ $record->repository }++;
  }
  return 1 if scalar keys %seen > 1;
  return;
}


sub in_repository {
  my ( $self, $repository ) = @_;
  return grep { $_->repository eq $repository }
    grep      { $_->has_versions } @{ $self->records };
}


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

no Moo;
no MooseX::Has::Sugar;

1;

__END__

=pod

=encoding utf-8

=head1 NAME

Gentoo::Perl::Distmap::RecordSet - A collection of Record objects representing versions in >1 repositories.

=head1 VERSION

version 0.1.4

=head1 ATTRIBUTES

=head2 records

=head1 METHODS

=head2 has_versions

	if( $instance->has_versions() ) {

	}

=head2 is_multi_repository

	if ( $instance->is_multi_repository() ){

	}

=head2 in_repository

	if ( my @records = $instance->in_repository('gentoo') ) {
		/* records from gentoo only */
	}

=head2 add_version

	$instance->add_version(
		category => 'gentoo-category',
		package  => 'gentoo-package',
		version  => 'gentoo-version',
		repository => 'gentoo-repository',
	);

=head2 to_rec

	my $datastructure = $instance->to_rec

=head1 CLASS METHODS

=head2 from_rec

	my $instance = G:P:D:RecordSet->from_rec( $datastructure );

=head1 ATTRIBUTE METHODS

=head2 records -> records

=head1 AUTHOR

Kent Fredric <kentfredric@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Kent Fredric <kentfredric@gmail.com>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
