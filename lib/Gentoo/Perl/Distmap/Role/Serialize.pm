use strict;
use warnings;

package Gentoo::Perl::Distmap::Role::Serialize;

# ABSTRACT: Basic utilities for serialising/sorting/indexing C<Distmap> nodes.

use Moo::Role;

=role_requires to_rec

=cut

requires to_rec =>;

=role_requires from_rec

=cut

requires from_rec =>;

=method hash

Returns C<SHA1> of C<<pp($instance->to_rec)>>

  $astring = $instance->hash()

=cut

sub hash {
  my ($self) = @_;
  require Data::Dump;
  my $rec = Data::Dump::pp( $self->to_rec );
  require Digest::SHA;
  return Digest::SHA::sha1_base64($rec);
}

no Moo::Role;

1;
