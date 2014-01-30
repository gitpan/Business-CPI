
use strict;
use warnings;

use 5.008;

use ExtUtils::MakeMaker 6.30;



my %WriteMakefileArgs = (
  "ABSTRACT" => "Common Payment Interface",
  "AUTHOR" => "Andr\x{e9} Walker <andre\@andrewalker.net>",
  "BUILD_REQUIRES" => {},
  "CONFIGURE_REQUIRES" => {
    "ExtUtils::MakeMaker" => "6.30"
  },
  "DISTNAME" => "Business-CPI",
  "EXE_FILES" => [],
  "LICENSE" => "perl",
  "NAME" => "Business::CPI",
  "PREREQ_PM" => {
    "Class::Load" => "0.20",
    "DateTime" => 0,
    "Email::Valid" => 0,
    "HTML::Element" => 0,
    "Locale::Country" => 0,
    "Locale::Currency" => 0,
    "Moo" => 1,
    "MooX::Types::MooseLike" => 0,
    "Scalar::Util" => 0
  },
  "TEST_REQUIRES" => {
    "Test::Exception" => "0.32"
  },
  "VERSION" => "0.914",
  "test" => {
    "TESTS" => "t/*.t"
  }
);


my %FallbackPrereqs = (
  "Class::Load" => "0.20",
  "DateTime" => 0,
  "Email::Valid" => 0,
  "HTML::Element" => 0,
  "Locale::Country" => 0,
  "Locale::Currency" => 0,
  "Moo" => 1,
  "MooX::Types::MooseLike" => 0,
  "Scalar::Util" => 0,
  "Test::Exception" => "0.32"
);


unless ( eval { ExtUtils::MakeMaker->VERSION(6.63_03) } ) {
  delete $WriteMakefileArgs{TEST_REQUIRES};
  delete $WriteMakefileArgs{BUILD_REQUIRES};
  $WriteMakefileArgs{PREREQ_PM} = \%FallbackPrereqs;
}

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.52) };

WriteMakefile(%WriteMakefileArgs);



