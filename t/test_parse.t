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
done_testing();
