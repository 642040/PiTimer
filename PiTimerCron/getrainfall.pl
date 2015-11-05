#!/usr/bin/perl -w
#$|++;	# Turn on autoflush

use warnings;
no warnings;

#use strict;
#use Geo::ShapeFile::Point comp_includes_z => 0, comp_includes_m => 0;
#use Geo::ShapeFile;
use Data::Dumper;
use LWP::Simple;        # Install using 'apt-get install libwww-perl'
use XML::LibXML;        # Install using 'apt-get install libxml-libxml-perl'

#my $date=shift();

chdir('/tmp');

my $target_Lat=shift();
my $target_Lon=shift();

if (!defined($target_Lat) || !defined($target_Lon)) {
	$target_Lat=33.295201;	# 1645 W Windsong
	$target_Lon=-112.096216;
}

#$date=~/(\d\d\d\d)(\d\d)(\d\d)/;

system("wget http://www.srh.noaa.gov/ridge2/Precip/qpehourlyshape/latest/last_24_hours.tar.gz");
system("tar -xvf last_24_hours.tar.gz");
my $hourly=get("http://api.wunderground.com/api/f2670ecbe98f8ba2/yesterday/q/${target_Lat},${target_Lon}.xml");

sub evapadj() {
	my $precipi=shift();
	my $remainder=0.0;
#	if(open(INFO,"/var/www/evapadj.txt")){
	if(open(INFO,"evapadj.txt")){
		while (my $line=<INFO>) {
		        if ($line=~s/^Remainder: (.*)$/$1/) {
		                $remainder=$1;
		        }
		}
		close INFO;
	}
	open(OUTF,">/var/www/evapadj.txt");
#	open(OUTF,">evapadj.txt");

	my $parser = XML::LibXML->new();
	my $xmlday=$parser->parse_string($hourly);
	
	my $totevap=0;
	print OUTF "TEMP\tHUM\tEVAP\n";
	foreach my $observation ($xmlday->findnodes('/response/history/observations/observation')) {
	        my $tempi=$observation->findvalue('tempi');
	        my $hum=$observation->findvalue('hum');
	        my $evap=-exp(15.58-3684/(273+($tempi-32)/1.8))*(1-$hum/100)/1350;
	        $totevap+=$evap;
	        print OUTF "$tempi\t$hum\t$evap\n";
	}
	
#	my $precipi=$xmlday->findvalue('/response/history/dailysummary/summary/precipi');
	print OUTF "Total Evaporation: $totevap\n";
	print OUTF "Rainfall: $precipi\n";
	$precipi+=$remainder;
	print OUTF "Rainfall(adj): $precipi\n";

	my $ratio=($totevap+$precipi)/-0.4286;
	$ratio= 0 >= $ratio ? 0 : $ratio;       #Lower limit zero
	$ratio = int($ratio * 100);
	print OUTF "Ratio: $ratio\%\n";

	if($precipi+$totevap>0){
	        $remainder=$precipi+$totevap;
	        print OUTF "Remainder: $remainder\n";
	}else{
	        print OUTF "Remainder: 0.0\n";
	}
	close(OUTF);
}
 
sub latlontohrap($$){
	use Math::Trig;	# Install using 'apt-get install libmath-complex-perl'
	my $rlat=shift();
	my $rlon=shift();
	
	my $d2rad=pi/180.0;
	my $earthr=6371.2;
	my $ref_lat=60.0;
	my $ref_lon=105.0;
	my $rmesh=4.7625;
	my $tlat=$ref_lat*$d2rad;
	my $re=($earthr*(1.+sin($tlat)))/$rmesh;
	my $flat=$rlat*$d2rad;
	my $flon=(-$rlon+180.-$ref_lon)*$d2rad;
	my $r=$re*cos($flat)/(1.0+sin($flat));
	my $x=$r*sin($flon);
	my $y=$r*cos($flon);
	my $hrap_x=int($x+401.0+0.5);
	my $hrap_y=int($y+1601.0+0.5);
	return ($hrap_x,$hrap_y);
}

sub getrainfall() {
	use Xbase;	# Install using CPAN: 'install Xbase'
	my ($Lat, $Lon) = @_;
	my ($hrap_x,$hrap_y) = &latlontohrap($Lat,$Lon);
	print "$hrap_x,$hrap_y\n";
	
	my $db = new Xbase;
	
	$db->open_dbf("latest/last_24_hours.dbf");
	my $dbend = $db->lastrec;
	
	my $i;
	my $rainfall = 0;
	do {
		$db->go_next;
		$i++;
		if ( $db->get_field("Hrapx") == $hrap_x ) {
			if ( $db->get_field("Hrapy") == $hrap_y ) {
				$rainfall = $db->get_field("Globvalue");
				$i        = $dbend + 1;
			}
		}
	} until ( $i > $dbend );
	$db->close_dbf;
	return ($rainfall);
}

print "$target_Lat,$target_Lon\n";

my $rainfall=&getrainfall($target_Lat,$target_Lon);
print "Rainfall: $rainfall\n";
&evapadj($rainfall);

system("rm last_24_hours.tar.gz");
