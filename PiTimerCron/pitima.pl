#! /usr/bin/perl
use strict;
use Device::BCM2835;

Device::BCM2835::init() || die "Could not init library";

my $cmdzone=shift();
my $cmd=shift();

my %Zones = (
	1=>&Device::BCM2835::RPI_GPIO_P1_07,
	2=>&Device::BCM2835::RPI_GPIO_P1_11,
	3=>&Device::BCM2835::RPI_GPIO_P1_19,
	4=>&Device::BCM2835::RPI_GPIO_P1_15,
	5=>&Device::BCM2835::RPI_GPIO_P1_12,
	6=>&Device::BCM2835::RPI_GPIO_P1_16,
	7=>&Device::BCM2835::RPI_GPIO_P1_18,
	8=>&Device::BCM2835::RPI_GPIO_P1_22,
);
	
foreach my $zone (keys %Zones) {
	if($cmd == "ON" && $cmdzone == $zone) {
		Device::BCM2835::gpio_fsel($Zones{$zone},&Device::BCM2835::BCM2835_GPIO_FSEL_OUTP);
        	Device::BCM2835::gpio_write($Zones{$zone},0);
	}else{
		Device::BCM2835::gpio_fsel($Zones{$zone},&Device::BCM2835::BCM2835_GPIO_FSEL_INPT);
	}
};
