use strict;
use warnings;

package Gentoo::Perl::Distmap::Role::Serialize;
BEGIN {
  $Gentoo::Perl::Distmap::Role::Serialize::AUTHORITY = 'cpan:KENTNL';
}
{
  $Gentoo::Perl::Distmap::Role::Serialize::VERSION = '0.1.3';
}

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

__END__
=pod

=encoding utf-8

=head1 NAME

Gentoo::Perl::Distmap::Role::Serialize - use Moo::Role;

=head1 VERSION

version 0.1.3

=head1 ROLE-REQUIRED METHODS

=head2 to_rec

=head2 from_rec

=head1 METHODS

=head2 hash

Returns SHA1 of pp($instance->to_rec)

  $astring = $instance->hash()

=head1 AUTHOR

Kent Fredric <kentfredric@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by Kent Fredric <kentfredric@gmail.com>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

