#!/usr/bin/env perl
use strict;
use warnings;
use LWP::UserAgent;
BEGIN {
    use HTTP::Request;
    $HTTP::Headers::TRANSLATE_UNDERSCORE = 0;
}
use HTTP::Cookies;
use feature qw(switch);

my $message = $ARGV[1];
my $phone = $ARGV[0];
my $api = "192.168.8.1";

package main;

my $ua = LWP::UserAgent->new;
my $request = HTTP::Request->new(GET => "http://" . $api . "/api/webserver/SesTokInfo");
my $response = $ua->request($request);
if (not $response->is_success)
{
	warn $response->as_string();
}
my $Session = getSession({ TokInfo => $response->decoded_content(), SesInfo => $response->decoded_content() });

my $header = HTTP::Headers->new;
$header->push_header("__RequestVerificationToken" => $Session->{'TokInfo'});
$header->push_header("Content-Type" => "text/xml");

my $data =
"<?xml version='1.0' encoding='UTF-8'?>" .
"<request>" .
    "<Index>-1</Index>" .
    "<Phones><Phone>" . $phone . "</Phone></Phones>" .
    "<Sca></Sca>" .
    "<Content>" . $message . "</Content>" .
    "<Length>" . length($message) . "</Length>" .
    "<Reserved>1</Reserved>" .
    "<Date>-1</Date>" .
"</request>";

$request = HTTP::Request->new(
  "POST",
  "http://" . $api . "/api/sms/send-sms",
  $header,
  $data,
);

$ua = new LWP::UserAgent();
my $cookie_jar = HTTP::Cookies->new();
$cookie_jar->set_cookie(0,"SessionID", $Session->{'SesInfo'},"/",$api);
$ua->cookie_jar($cookie_jar);

my $post = $ua->request($request);
if (not $response->is_success) { warn $response->as_string(); }
print getErr($post->decoded_content());

sub getSession
{
	my $param = shift;
	return { 
		TokInfo => $param->{'TokInfo'} =~ /<TokInfo>(.*?)<\/TokInfo>/,
		SesInfo => $param->{'SesInfo'} =~ /<SesInfo>SessionID=(.*?)<\/SesInfo>/
	};
}
sub getErr
{
	my $int = shift;
	my $st;
	switch:
	{
		if ($int =~ /<code>125002<\/code>/) { $st = "Invalid token"; }
		if ($int =~ /<code>100002<\/code>/) { $st = "Unknown API function" ; }
		if ($int =~ /<response>OK<\/response>/) { $st = "SMS Send";}
	}
	return $st;
}
