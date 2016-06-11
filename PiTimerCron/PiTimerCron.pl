#! /usr/bin/perl
use FindBin;
use lib $FindBin::Bin;
use strict;
use MakeSchedule;
use Data::Dumper;

chdir('/tmp');

localtime() =~ /^(...).*(\d\d):(\d\d):(\d\d)/;	#"Thu Oct 13 04:54:34 1994"
my $day     = $1;
my $CurTime = $2 * 60 + $3;
my $today = sprintf( "%4d-%02d-%02d",
	(localtime)[5] + 1900,
	(localtime)[4] + 1,
	(localtime)[3] );

use Device::BCM2835;

Device::BCM2835::init() || die "Could not init library";

my %Zones   = (
        1=>&Device::BCM2835::RPI_GPIO_P1_12,
#       2=>&Device::BCM2835::RPI_GPIO_P1_13,
        3=>&Device::BCM2835::RPI_GPIO_P1_15,
        4=>&Device::BCM2835::RPI_GPIO_P1_16,
        5=>&Device::BCM2835::RPI_GPIO_P1_18,
        6=>&Device::BCM2835::RPI_GPIO_P1_22,
        7=>&Device::BCM2835::RPI_GPIO_P1_07,
        8=>&Device::BCM2835::RPI_GPIO_P1_11,
);

my @DayList = qw( Sun Mon Tue Wed Thu Fri Sat );

my %Schedule=MakeSchedule();

foreach my $zone ( keys %Zones ) {
	if ( defined( $Schedule{$day}{$CurTime} )
		&& $Schedule{$day}{$CurTime} == $zone )
	{
		#print "$zone ON\n";
		Device::BCM2835::gpio_fsel( $Zones{$zone},
			&Device::BCM2835::BCM2835_GPIO_FSEL_OUTP );
		Device::BCM2835::gpio_write( $Zones{$zone}, 0 );
	}
	else {
		#print "$zone OFF\n";
		Device::BCM2835::gpio_fsel( $Zones{$zone},
                        &Device::BCM2835::BCM2835_GPIO_FSEL_OUTP );
                Device::BCM2835::gpio_write( $Zones{$zone}, 1 );
	}
}
