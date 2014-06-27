#!/usr/bin/perl -w

#
#	Modify zone names called by bound submit in PiTimer.js
#
#	Adrian Allan 9/9/2013
#

use strict;
use CGI ':standard';
use Data::Dumper;
use XML::LibXML;
open(JUNK,">junk.txt");

my $parser = XML::LibXML->new();
my $PiTimer = $parser->parse_file('./PiTimer.xml');

my $query = new CGI;

my @names = $query->param;
for my $name (@names) {
	my $value = $query->param($name);
	print JUNK "$name : $value\n";
	if($name=~(/textinput(\d)/)) {
		my $xpath="PiTimer/Zones/Zone[\@ZoneID=\"$1\"]";
		my ($ZoneName)=$PiTimer->findnodes($xpath);
		$ZoneName->removeChildNodes();
		$ZoneName->appendText($value);
	}
}
$PiTimer->toFile("./PiTimer.xml");


print header();