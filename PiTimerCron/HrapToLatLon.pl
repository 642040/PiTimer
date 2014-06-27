#! /usr/bin/perl -w
use strict;
use Math::Trig;

sub HrapToLatLon($$){
	use Math::Trig;
	my $hrap_x=shift();
	my $hrap_y=shift();
	
	my $earthr=6371.2;
	my $stlon=105.0;
	my $raddeg=180.0/pi;
	my $xmesh=4.7625;
	my $tlat=60.006814/$raddeg;
	my $x=$hrap_x-401.0;
	my $y=$hrap_y-1601.0;
	my $rr=$x*$x+$y*$y;
	my $gi=(($earthr*(1.0+sin($tlat)))/$xmesh);
	$gi=$gi*$gi;
	my $rlat=asin(($gi-$rr)/($gi+$rr))*$raddeg;
	my $ang=atan2($y,$x)*$raddeg;
	if($ang<0.0) {
		$ang=$ang+360.0;
	}
	my $rlon=270.0+$stlon-$ang;
	if($rlon<-180.0) {
		$rlon=$rlon+360.0;
	}
	if($rlon>180.0){
		$rlon=$rlon-360.0;
	}
	return ($rlat,$rlon)
}

sub latlontohrap($$){
	use Math::Trig;
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

(my $hrap_x,my $hrap_y)=latlontohrap(33.295201,-112.096216);
print "$hrap_x,$hrap_y\n";

(my $rlat,my $rlon)=HrapToLatLon($hrap_x,$hrap_y);
print "$rlat,$rlon\n";

($rlat,$rlon)=HrapToLatLon(235,264);
print "$rlat,$rlon\n";
