#!/usr/bin/perl -w

#
#	Inserts new program in PiTimer.xml
#	Called by addProgram in PTedits.js
#
#	Adrian Allan 9/9/2013
#

use strict;
use CGI ':standard';
use XML::LibXML;

#	Load existing PiTimer.xml
my $parser = XML::LibXML->new();
my $PiTimer = $parser->parse_file('./PiTimer.xml');

#	Initiate CGI even though it is not reallty used in this case
my $query = new CGI;

#	Schedule node in tree
my $xpath="PiTimer/Schedule";
my ($Schedules)=$PiTimer->findnodes($xpath);

#	Build new program blank
my $newProgram = <<STREND;
                <Program name="New Program">
                        <Day>Sun</Day>
                        <Day>Mon</Day>
                        <Day>Tue</Day>
                        <Day>Wed</Day>
                        <Day>Thu</Day>
                        <Day>Fri</Day>
                        <Day>Sat</Day>
                        <StartTime>00:00:00</StartTime>
                </Program>
STREND

#	Create fragment of XML from the program blank string
my $fragment = $parser->parse_balanced_chunk($newProgram);

#	Append the fragment to the Schedules node
$Schedules->appendChild($fragment);
$PiTimer->toFile("./PiTimer.xml");

#	Return empty data to Post request
print header();
print start_html();
print end_html();
