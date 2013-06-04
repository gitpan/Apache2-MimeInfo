use inc::Module::Install;

name     'Apache2-MimeInfo';
all_from 'lib/Apache2/MimeInfo.pm';
author   q{Dorian Taylor <dorian@cpan.org>};
license  'apache';

requires 'File::MimeInfo';
requires 'IO::Scalar';

build_requires 'Test::More';
build_requires 'Apache::Test';

clean_files 't/TEST t/SMOKE';

require Apache::TestMM;
Apache::TestMM->import(qw(test clean));

Apache::TestMM::filter_args();
Apache::TestMM::generate_script('t/TEST');

auto_install;

WriteAll;

