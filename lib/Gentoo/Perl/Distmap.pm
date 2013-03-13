use strict;
use warnings;

package Gentoo::Perl::Distmap;

# ABSTRACT: A reader/writer for the metadata/perl/distmap.json file.

use 5.010000;
use Moo;
use MooseX::Has::Sugar qw( rw );
use Sub::Quote qw( quote_sub );

=head1 SYNOPSIS

	my $dm  = Gentoo::Perl::Distmap->load(  file => '../path/to/distmap.json' );
	$dm->save( file => '/tmp/foo.x' );

	for my $dist ( sort $dm->dists_in_repository('gentoo') ) {
		/* see the upstream distnames visible in gentoo */
	}
	for my $dist ( sort $dm->dists_in_repository('perl-experimental') ) {
		/* see the upstream distnames visible in perl-experimental */
	}
	for my $dist ( sort $dm->multi_repository_dists ) {
		/* see the dists that exist in more than one repository */
	}
-	for my $dist ( sort $dm->mapped_dists ) {
		/* see the dists that have at least one version in the dataset */
		/* note: dists with empty version sets should be deemed a bug  */
	}

Interface for creating/augmenting/comparing .json files still to be defined, basic functionality only at this time.


=cut

=attr map

=attr_method map -> map

=attr_method multi_repository_dists -> map

=attr_method all_mapped_dists -> map

=attr_method mapped_dists -> map

=attr_method dists_in_repository -> map

=attr_method add_version -> map

=cut

has map => ( rw,
  default => quote_sub(q| require Gentoo::Perl::Distmap::Map; Gentoo::Perl::Distmap::Map->new() |),
  handles => [qw( multi_repository_dists all_mapped_dists mapped_dists dists_in_repository add_version )],
);

=classmethod load

	my $instance = G:P:Distmap->load( file => $filepath );
	my $instance = G:P:Distmap->load( filehandle => $fh );
	my $instance = G:P:Distmap->load( string => $str );

=cut

sub load {
  my ( $self, $method, $source ) = @_;
  require Gentoo::Perl::Distmap::Map;
  return $self->new(
    map => Gentoo::Perl::Distmap::Map->from_rec(
      $self->decoder->decode( $self->can( '_load_' . $method )->( $self, $method, $source ) )
    )
  );
}

=method save

	$instance->save( file => $filepath );
	$instance->save( filehandle => $fh );
	my $string = $instance->save( string => );

=cut

sub save {
  my ( $self, $method, $target ) = @_;
  return $self->can( '_save_' . $method )->( $self, $self->encoder->encode( $self->map->to_rec ), $target );
}

=p_method _save_string

=p_method _save_filehandle

=p_method _save_file

=cut

sub _save_string     { return $_[1] }
sub _save_filehandle { return $_[2]->print( $_[1] ) }
sub _save_file       { require Path::Tiny; return $_[0]->_save_filehandle( $_[1], Path::Tiny::path( $_[2] )->openw() ) }

=pc_method _load_file

=pc_method _load_filehandle

=pc_method _load_string

=cut

sub _load_file { require Path::Tiny; return scalar Path::Tiny::path( $_[2] )->slurp() }
sub _load_filehandle { local $/ = undef; return scalar $_[2]->getline }
sub _load_string { return $_[2] }

=classmethod decoder

	$decoder = G:P:Distmap->decoder();

=classmethod encoder

	$encoder = G:P:Distmap->encoder();
=cut

sub decoder {
  return state $json = do { require JSON; JSON->new->pretty->utf8->canonical; }
}

sub encoder {
  return state $json = do { require JSON; JSON->new->pretty->utf8->canonical; }
}

no Moo;
no MooseX::Has::Sugar;

1;

