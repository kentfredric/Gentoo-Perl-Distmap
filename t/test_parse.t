use strict;
use warnings;

use Test::More;
use 5.10.0;
use FindBin;
use Path::Class::Dir;
my $corpus = Path::Class::Dir->new($FindBin::Bin)->parent->subdir('corpus');

use Gentoo::Perl::Distmap;

my $dm = Gentoo::Perl::Distmap->load( file => $corpus->file('distmap.json') );
pass("loaded without failing");

my $dmx = Gentoo::Perl::Distmap->new();
$dmx->add_version(
  distribution => Test   =>,
  category     => fake   =>,
  package      => fake   =>,
  version      => '0.01' =>,
  repository   => 'fake',
);
$dmx->add_version(
  distribution => Test   =>,
  category     => fake   =>,
  package      => fake   =>,
  version      => '0.01' =>,
  repository   => 'fake',
);

use Data::Dump qw(pp);
say pp($dmx);
say $dmx->save( string => );
done_testing();
