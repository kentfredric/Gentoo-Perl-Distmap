use strict;
use warnings;

package Gentoo::Perl::Distmap;
BEGIN {
  $Gentoo::Perl::Distmap::AUTHORITY = 'cpan:KENTNL';
}
{
  $Gentoo::Perl::Distmap::VERSION = '0.1.0';
}

# ABSTRACT: A reader/writer for the metadata/perl/distmap.json file.

use 5.010000;
use Gentoo::Perl::Distmap::Record;
use Gentoo::Perl::Distmap::Map;

use Moo;
use MooseX::Has::Sugar qw( rw );
use Sub::Quote qw( quote_sub );


has map => ( rw,
  default => quote_sub(q| require Gentoo::Perl::Distmap::Map; Gentoo::Perl::Distmap::Map->new() |),
  handles => [qw( multi_repo_dists all_mapped_dists mapped_dists dists_in_repo )],
);

sub load {
  my ( $self, $method, $source ) = @_;
  return $self->new(
    map => Gentoo::Perl::Distmap::Map->from_rec(
      $self->decoder->decode( $self->can( '_load_' . $method )->( $self, $method, $source ) )
    )
  );
}

sub save {
  my ( $self, $method, $target ) = @_;
  return $self->can( '_save_' . $method )->( $self, $self->encoder->encode( $self->map->to_rec ), $target );
}

sub _save_string     { return $_[1] }
sub _save_filehandle { return $_[2]->print( $_[1] ) }
sub _save_file       { require Path::Class::File; return $_[0]->_save_filehandle( $_[1], Path::Class::File->new( $_[2] )->openw() ) }

sub _load_file { require Path::Class::File; return scalar Path::Class::File->new( $_[2] )->slurp() }
sub _load_filehandle { local $/ = undef; return scalar $_[2]->getline }
sub _load_string { return $_[2] }

sub decoder {
  return state $json = do { require JSON; JSON->new->pretty->utf8->canonical; }
}

sub encoder {
  return state $json = do { require JSON; JSON->new->pretty->utf8->canonical; }
}

no Moo;

1;


__END__
=pod

=encoding utf-8

=head1 NAME

Gentoo::Perl::Distmap - A reader/writer for the metadata/perl/distmap.json file.

=head1 VERSION

version 0.1.0

=head1 SYNOPSIS

	my $dm  = Gentoo::Perl::Distmap->load(  file => '../path/to/distmap.json' );
	$dm->save( file => '/tmp/foo.x' );

	for my $dist ( sort $dm->dists_in_repo('gentoo') ) {
		/* see the upstream distnames visible in gentoo */
	}
	for my $dist ( sort $dm->dists_in_repo('perl-experimental') ) {
		/* see the upstream distnames visible in perl-experimental */
	}
	for my $dist ( sort $dm->multi_repo_dists ) {
		/* see the dists that exist in more than one repo */
	}
-	for my $dist ( sort $dm->mapped_dists ) {
		/* see the dists that have at least one version in the dataset */
		/* note: dists with empty version sets should be deemed a bug  */
	}

Interface for creating/augmenting/comparing .json files still to be defined, basic functionality only at this time.

=head1 AUTHOR

Kent Fredric <kentfredric@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by Kent Fredric <kentfredric@gmail.com>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

