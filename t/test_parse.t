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
for my $i ( 0 .. 200 ) {
  $dmx->add_version(
    distribution => Test       =>,
    category     => fake       =>,
    package      => fake       =>,
    version      => '0.0' . $i =>,
    repository   => 'fake',
  );
}
pass("added 200 new versions successfully");
is( length $dmx->save( string => ), 4483, "Saved JSON is expected 4483 chars long" );

done_testing();
