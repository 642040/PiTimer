#! /usr/bin/perl
use strict;

use LWP::Simple;	# Install using 'apt-get install libwww-perl'
use XML::LibXML;	# Install using 'apt-get libxml-libxml-perl'

my $yesterday=get('http://api.wunderground.com/api/f2670ecbe98f8ba2/yesterday/q/33.295278,-112.096111.xml');
#open (INFO,"hist.txt");
#my $yesterday=join('',<INFO>);
#close INFO;

my $remainder=0.0;
open(INFO,"/var/www/PiTimer/evapadj.txt");
while (my $line=<INFO>) {
        if ($line=~s/^Remainder: (.*)$/$1/) {
                $remainder=$1;
        }
}
close INFO;

open(OUTF,">/var/www/PiTimer/evapadj.txt");

my $parser = XML::LibXML->new();
my $xmlday=$parser->parse_string($yesterday);

my $totevap=0;
print OUTF "TEMP\tHUM\tEVAP\n";
foreach my $observation ($xmlday->findnodes('/response/history/observations/observation')) {
	my $tempi=$observation->findvalue('tempi');
	my $hum=$observation->findvalue('hum');
	my $evap=-exp(15.58-3684/(273+($tempi-32)/1.8))*(1-$hum/100)/1350;
	$totevap+=$evap;
	print OUTF "$tempi\t$hum\t$evap\n";
}

my $precipi=$xmlday->findvalue('/response/history/dailysummary/summary/precipi');
print OUTF "Total Evaporation: $totevap\n";
print OUTF "Rainfall: $precipi\n";
$precipi+=$remainder;
print OUTF "Rainfall(adj): $precipi\n";
if($precipi+$totevap>0){
	$remainder=$precipi+$totevap;
	print OUTF "Ratio: 0.0\n";
	print OUTF "Remainder: $remainder\n";
}else{
	my $ratio=($totevap+$precipi)/-0.4286;
	print OUTF "Ratio: $ratio\n";
	print OUTF "Remainder: 0.0\n";
}
close(OUTF);
