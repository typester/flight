package FCGI::Server::Lighttpd;
use Moose;

use Cwd ();
use File::Which;
use File::Temp;
use String::TT qw/tt strip/;
use MIME::Types;

our $VERSION = '0.0001';

with 'MooseX::Getopt';

has port => (
    metaclass   => 'Getopt',
    cmd_aliases => 'p',
    is          => 'rw',
    isa         => 'Int',
    default     => 4423,
);

has lighttpd => (
    metaclass   => 'Getopt',
    cmd_aliases => 'l',
    is          => 'rw',
    isa         => 'Str',
    default     => sub { which('lighttpd') || '/usr/sbin/lighttpd' },
);

has nprocs => (
    metaclass   => 'Getopt',
    cmd_aliases => 'n',
    is          => 'rw',
    isa         => 'Int',
    default     => 1,
);

has docroot => (
    metaclass   => 'Getopt',
    cmd_aliases => [qw/root d/],
    is          => 'rw',
    isa         => 'Str',
    default     => sub { Cwd::getcwd() },
);

has static => (
    metaclass   => 'Getopt',
    cmd_aliases => 's',
    is          => 'rw',
    isa         => 'Str',
    default     => '([^/]+\.[^/]+$|css/|images?/|js/|static/)',
);

sub run {
    my ($self, $fcgi) = @_;
    $fcgi = Cwd::abs_path($fcgi);

    my $mime_types = do {
        my $res = "mimetype.assign = (\n";
        my %known_extensions;
        my $types = MIME::Types->new(only_complete => 1);
        for my $type ( $types->types ) {
            for my $ext ( sort map { lc } $type->extensions ) {
                next if $known_extensions{$ext}++;
                $res .= qq{".$ext" => "$type",\n};
            }
        }
        $res .= ")\n";
        $res;
    };

    my $socket = File::Temp->new;
    $socket->close;

    my $config = tt q{
        server.modules = ( "mod_fastcgi" )

        [% mime_types %]

        server.document-root = "[% self.docroot %]"
        server.port = [% self.port %]

        [%- IF self.static %]
        $HTTP["url"] =~ "^/(?![% self.static %])" {
        [%- END %]
            fastcgi.server = (
                "" => (
                    (
                        "socket" => "[% socket.filename %]",
                        "bin-path" => "[% fcgi %]",
                        "check-local" => "disable",
                        "allow-x-send-file" => "enable",
                        "max-procs" => [% self.nprocs %],
                    ),
                )
            )
        [%- IF self.static %]}[% END %]
    };

    my $fh = File::Temp->new;
    print $fh $config;
    $fh->close;

    system $self->lighttpd, qw/-D -f/, $fh->filename;
}

=head1 NAME

FCGI::Server::Lighttpd - Module abstract (<= 44 characters) goes here

=head1 SYNOPSIS

  use FCGI::Server::Lighttpd;
  blah blah blah

=head1 DESCRIPTION

Stub documentation for this module was created by ExtUtils::ModuleMaker.
It looks like the author of the extension was negligent enough
to leave the stub unedited.

Blah blah blah.

=head1 AUTHOR

Daisuke Murase <typester@cpan.org>

=head1 COPYRIGHT

This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

The full text of the license can be found in the
LICENSE file included with this module.

=cut

1;
