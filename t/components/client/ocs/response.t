#!/usr/bin/perl

use strict;
use warnings;
use lib 't';

use Compress::Zlib;
use English qw(-no_match_vars);
use Socket;
use Test::More;
use Test::Exception;

use FusionInventory::Agent::Logger;
use FusionInventory::Agent::HTTP::Client::OCS;
use FusionInventory::Agent::XML::Query;
use FusionInventory::Test::Server;
use FusionInventory::Test::Proxy;

if ($OSNAME eq 'MSWin32') {
    plan skip_all => 'non working test on Windows';
} else {
    plan tests => 6;
}

my $logger = FusionInventory::Agent::Logger->new(
    backends => [ 'Test' ]
);

my $message = FusionInventory::Agent::XML::Query->new(
    deviceid => 'foo',
    query => 'foo',
    msg => {
        foo => 'foo',
        bar => 'bar'
    },
);

my $client = FusionInventory::Agent::HTTP::Client::OCS->new(
    logger => $logger
);

# no connection tests
BAIL_OUT("port aleady used") if test_port(8080);

# http connection tests
my ($server, $response);

$server = FusionInventory::Test::Server->new(
    port => 8080,
);
my $header  = "HTTP/1.0 200 OK\r\n\r\n";
my $xml_content  = "<REPLY><word>hello</word></REPLY>";
my $html_content = "<html><body>hello</body></html>";
$server->set_dispatch({
    '/error'        => sub { print "HTTP/1.0 403 NOK\r\n\r\n"; },
    '/empty'        => sub { print $header; },
    '/uncompressed' => sub { print $header . $html_content; },
    '/unexpected'   => sub { print $header . compress($html_content); },
    '/correct'      => sub { print $header . compress($xml_content); },
    '/altered'      => sub { print $header . "\n" . compress($xml_content); },
});
$server->background() or BAIL_OUT("can't launch the server");

subtest "error response" => sub {
    check_response_nok(
        scalar $client->send(
            message => $message,
            url     => 'http://localhost:8080/error',
        ),
        $logger,
        "[client] error response: 403 NOK",
    );
};

subtest "empty content" => sub {
    check_response_nok(
        scalar $client->send(
            message => $message,
            url     => 'http://localhost:8080/empty',
        ),
        $logger,
        "[client] empty content",
    );
};

subtest "uncompressed content" => sub {
    check_response_nok(
        scalar $client->send(
            message => $message,
            url     => 'http://localhost:8080/uncompressed',
        ),
        $logger,
        "[client] uncompressed content, starting with $html_content",
    );
};

subtest "unexpected content" => sub {
    check_response_nok(
        scalar $client->send(
            message => $message,
            url     => 'http://localhost:8080/unexpected',
        ),
        $logger,
        "[client] unexpected content, starting with $html_content",
    );
};

subtest "correct response" => sub {
    check_response_ok(
        scalar $client->send(
            message => $message,
            url     => 'http://localhost:8080/correct',
        ),
    );
};

subtest "altered response" => sub {
    check_response_ok(
        scalar $client->send(
            message => $message,
            url     => 'http://localhost:8080/altered',
        ),
    );
};

$server->stop();

sub check_response_ok {
    my ($response) = @_;

    plan tests => 3;
    ok(defined $response, "response from server");
    isa_ok(
        $response,
        'FusionInventory::Agent::XML::Response',
        'response class'
    );
    my $content = $response->getContent();
    is_deeply(
        $content,
        { word => 'hello' },
        'response content'
    );
}

sub check_response_nok {
    my ($response, $logger, $message) = @_;

    plan tests => 3;
    ok(!defined $response,  "no response");
    is(
        $logger->{backends}->[0]->{level},
        'error',
        "error message level"
    );
    if (ref $message eq 'Regexp') {
        like(
            $logger->{backends}->[0]->{message},
            $message,
            "error message content"
        );
    } else {
        is(
            $logger->{backends}->[0]->{message},
            $message,
            "error message content"
        );
    }
}

sub test_port {
    my $port   = $_[0];

    my $iaddr = inet_aton('localhost');
    my $paddr = sockaddr_in($port, $iaddr);
    my $proto = getprotobyname('tcp');
    if (socket(my $socket, PF_INET, SOCK_STREAM, $proto)) {
        if (connect($socket, $paddr)) {
            close $socket;
            return 1;
        } 
    }

    return 0;
}