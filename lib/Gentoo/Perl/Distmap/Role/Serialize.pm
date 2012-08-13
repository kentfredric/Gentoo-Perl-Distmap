use strict;
use warnings;

package Gentoo::Perl::Distmap::Role::Serialize;

# ABSTRACT:

use Moo::Role;

requires to_rec   =>;
requires from_rec =>;

sub hash {
  my ($self) = @_;
  require Data::Dump;
  my $rec = Data::Dump::pp( $self->to_rec );
  require Digest::SHA;
  return Digest::SHA::sha1_base64($rec);
}

no Moo::Role;

1;
