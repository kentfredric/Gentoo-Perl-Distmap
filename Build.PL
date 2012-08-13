
use strict;
use warnings;

use Module::Build 0.3601;


my %module_build_args = (
  "build_requires" => {
    "File::Find" => 0,
    "File::Temp" => 0,
    "FindBin" => 0,
    "Module::Build" => "0.4002",
    "Path::Class::Dir" => 0,
    "Test::More" => "0.98",
    "perl" => "v5.10.0"
  },
  "configure_requires" => {
    "Module::Build" => "0.4002"
  },
  "dist_abstract" => "A reader/writer for the metadata/perl/distmap.json file.",
  "dist_author" => [
    "Kent Fredric <kentfredric\@gmail.com>"
  ],
  "dist_name" => "Gentoo-Perl-Distmap",
  "dist_version" => "0.1.3",
  "license" => "perl",
  "module_name" => "Gentoo::Perl::Distmap",
  "recommends" => {},
  "recursive_test_files" => 1,
  "requires" => {
    "Carp" => 0,
    "Data::Dump" => 0,
    "Digest::SHA" => 0,
    "JSON" => 0,
    "Moo" => 0,
    "Moo::Role" => 0,
    "MooseX::Has::Sugar" => 0,
    "Path::Class::File" => 0,
    "Sub::Quote" => 0,
    "perl" => "v5.10.0",
    "strict" => 0,
    "warnings" => 0
  },
  "script_files" => []
);


my $build = Module::Build->new(%module_build_args);

$build->create_build_script;
