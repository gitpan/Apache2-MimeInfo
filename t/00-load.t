#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'Apache2::MimeInfo' ) || print "Bail out!\n";
}

diag( "Testing Apache2::MimeInfo $Apache2::MimeInfo::VERSION, Perl $], $^X" );
