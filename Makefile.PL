use strict;
use warnings;

use ExtUtils::MakeMaker;

WriteMakefile(
  VERSION   => '0.01',
  PREREQ_PM => {
    'Mojolicious' => '9.37',
    'Mojolicious::Plugin::OpenAPI',
    'Mojolicious::Plugin::SwaggerUI',
    'OpenAPI::Client',
    'YAML::XS'
  },
  test => {TESTS => 't/*.t'}
);
