package Apache2::MimeInfo;

use 5.010;
use strict;
use warnings FATAL => 'all';

use base qw(Apache2::Filter);

use Apache2::Const -compile => qw(OK DECLINED HTTP_BAD_GATEWAY);
use APR::Const     -compile => qw(SUCCESS);

use Apache2::Log         ();
use Apache2::FilterRec   ();
use Apache2::RequestRec  ();
use Apache2::RequestUtil ();

use APR::Table   ();
use APR::Bucket  ();
use APR::Brigade ();

use IO::Scalar ();

BEGIN {
    # do this because holy god File::BaseDir is annoying
    # no need to local
    #local $ENV{HOME};
    if ($ENV{MOD_PERL}) {
        use Apache2::ServerUtil ();
        $ENV{HOME} ||= Apache2::ServerUtil::server_root();
    }

    # shut UPPP
    require File::MimeInfo::Magic;
}

=head1 NAME

Apache2::MimeInfo - Content-Type header informed by File::MimeInfo

=head1 VERSION

Version 0.03

=cut

our $VERSION = '0.03';


=head1 SYNOPSIS

    PerlLoadModule Apache2::MimeInfo
    PerlOutputFilterHandler Apache2::MimeInfo

=head1 DESCRIPTION

=cut

my %SKIP = (
    'application/x-gzip'     => 1,
    'application/x-compress' => 1,
    'application/x-bzip2'    => 1,
);

sub handler : FilterRequestHandler {
    my ($f, $bb) = @_;

    unless ($f->ctx) {
        my $r = $f->r;

        my $type = $r->content_type || $r->default_type;

        # XXX not sure if the first bucket is going to be the right one
        my $b = $bb->first;
        if ($b->read(my $data)) {
            my $io = IO::Scalar->new(\$data);
            my $mg = File::MimeInfo::Magic->new;
            my $mt = $mg->mimetype($io);
            $r->log->debug("Content type asserted: $type, Detected: $mt");
            if ($mg->mimetype_isa($type, $mt)) {
                $r->log->debug("Leaving more-specific type alone");
            }
            elsif ($SKIP{$mt}) {
                # one day we can actually inspect the uncompressed contents.
                $r->log->debug("Not replacing $type with $mt.");
            }
            else {
                $r->log->debug("Replacing content type on " . $r->uri);
                $r->content_type($mt);
            }
        }

        $f->ctx(1);
    }
    Apache2::Const::DECLINED;
}

=head1 AUTHOR

Dorian Taylor, C<< <dorian at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-apache2-mimeinfo
at rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Apache2-MimeInfo>.  I
will be notified, and then you'll automatically be notified of
progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Apache2::MimeInfo

You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Apache2-MimeInfo>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Apache2-MimeInfo>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Apache2-MimeInfo>

=item * Search CPAN

L<http://search.cpan.org/dist/Apache2-MimeInfo/>

=back

=head1 SEE ALSO

=over 4

=item L<File::MimeInfo>

=back

=head1 LICENSE AND COPYRIGHT

Copyright 2013 Dorian Taylor.

Licensed under the Apache License, Version 2.0 (the "License"); you
may not use this file except in compliance with the License. You may
obtain a copy of the License at
L<http://www.apache.org/licenses/LICENSE-2.0> .

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
implied.  See the License for the specific language governing
permissions and limitations under the License.

=cut

1; # End of Apache2::MimeInfo
