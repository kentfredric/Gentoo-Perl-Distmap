use strict;
use warnings;

package Gentoo::Perl::Distmap::RecordSet;
BEGIN {
  $Gentoo::Perl::Distmap::RecordSet::AUTHORITY = 'cpan:KENTNL';
}
{
  $Gentoo::Perl::Distmap::RecordSet::VERSION = '0.1.0';
}

# ABSTRACT: A collection of Record objects representing versions in >1 repos.

use Moo;
use MooseX::Has::Sugar qw( rw );
use Sub::Quote qw( quote_sub );


has 'records' => rw, default => quote_sub(q{ [] });


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
no Moo;
no MooseX::Has::Sugar;

1;

__END__
=pod

=encoding utf-8

=head1 NAME

Gentoo::Perl::Distmap::RecordSet - A collection of Record objects representing versions in >1 repos.

=head1 VERSION

version 0.1.0

=head1 ATTRIBUTES

=head2 records

=head1 METHODS

=head2 has_versions

	if( $instance->has_versions() ) {
	
	}

=head2 is_multi_repo

	if ( $instance->is_multi_repo() ){

	}

=head2 in_repo

	if ( my @records = $instance->in_repo('gentoo') ) {
		/* records from gentoo only */
	}

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

This software is copyright (c) 2012 by Kent Fredric <kentfredric@gmail.com>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
