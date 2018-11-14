#!/usr/bin/env perl
use strict;
use warnings;
use LWP::UserAgent;
BEGIN {
    use HTTP::Request;
    $HTTP::Headers::TRANSLATE_UNDERSCORE = 0;
}
use HTTP::Cookies;

my $message = $ARGV[1];
my $phone = $ARGV[0];
my $api = "192.168.8.1";

package main;

my $getua = LWP::UserAgent->new;
my $getrequest = HTTP::Request->new(GET => "http://" . $api . "/api/webserver/SesTokInfo");
my $getresponse = $getua->request($getrequest);

my $postheader = HTTP::Headers->new;
$postheader->push_header("__RequestVerificationToken" => $getresponse->decoded_content =~ /<TokInfo>(.*?)<\/TokInfo>/);
$postheader->push_header("Content-Type" => "text/xml");

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

my $postrequest = HTTP::Request->new(
  "POST",
  "http://" . $api . "/api/sms/send-sms",
  $postheader,
  $data,
);

my $postua = new LWP::UserAgent();
my $cookie_jar = HTTP::Cookies->new();
$cookie_jar->set_cookie(0,"SessionID", $getresponse->decoded_content =~ /<SesInfo>SessionID=(.*?)<\/SesInfo>/,"/",$api);
$postua->cookie_jar($cookie_jar);

my $postresponse = $postua->request($postrequest);
print($postrequest->as_string());
print($postresponse->as_string());