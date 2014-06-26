#! /usr/bin/perl
use strict;
use MakeSchedule;
use Imager;

my @Colors = qw(Red Orange Yellow LightGreen DarkGreen LightBlue Blue Purple);

my @DOW = qw(Sun Mon Tue Wed Thu Fri Sat);

my %Schedule=MakeSchedule();

my $font=Imager::Font->new(file=>"arial.ttf");
my $xsize=300;
my $ysize=300;
my $img=Imager->new(xsize=>$xsize*7,ysize=>$ysize,channels=>4);
$img->box(color=>"Black", xmin=>0, ymin=>0, xmax=>$xsize*7, ymax=>$ysize, filled=>1);
my $fontsize=($xsize/24+$ysize/60);

for (my $day=0; $day<=6; $day++) {
	my $xoffset=($day)*$xsize;


	for (my $time=0;$time<1440;$time++) {
		if(defined $Schedule{$DOW[$day]}{$time}) {
			my $zone=$Schedule{$DOW[$day]}{$time};
			while(defined $Schedule{$DOW[$day]}{$time} && $Schedule{$DOW[$day]}{$time}==$zone) {
				# Draw Box for each zone
				my $xmin=$xoffset+int(($xsize/24)*int($time/60));
				my $xmax=$xoffset+int(($xsize/24)*int(1+$time/60));
				my $ymax=$ysize-int(($ysize/60)*($time%60));
				my $ymin=$ysize-int(($ysize/60)*(1+($time)%60));
				$img->box(color=>$Colors[$zone-1], xmin=> $xmin, ymin=>$ymin, xmax=>$xmax, ymax=>$ymax, filled=>1);
#				if($i==1) {
#					$tagx=$xmin;
#					$tagy=$ymax;
#				}
				$time++;
#				$fontsize=$xsize/12;
#				$img->string(x=>$tagx,y=>$tagy,string=>$zone,font=>$font,size=>$fontsize,aa=>1,color=>'white');
			}
		}
	}
	for my $i (qw(0 6 12 18)) {
		# Hours on X axis
		$img->string(x=>$xoffset+int(($xsize/24)*$i)-.25*$fontsize,y=>$ysize,string=>$i,font=>$font,size=>$fontsize,aa=>1,color=>'white');
	}
	for my $j (qw(15 30 45)) {
		# Minutes on Y axis
		$img->string(x=>$xoffset+0,y=>$ysize-int(($ysize/60)*$j),string=>$j,font=>$font,size=>$fontsize,aa=>1,color=>'white');
	}
	# Add Title for each day
	$fontsize=2*($xsize/24+$ysize/60);
	$img->string(x=>$xoffset+int($xsize/2),y=>$fontsize,string=>$DOW[$day],font=>$font,size=>$fontsize,aa=>1,color=>'white');
}

$img->write(file=>"week.png", type=>"png")or die "Cannot write: ",$img->errstr;
