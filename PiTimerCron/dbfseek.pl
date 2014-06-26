#!/usr/bin/perl
use strict;

my $hrap_x = 235;
my $hrap_y = 264;

my $rainfall = getrainfall( $hrap_x, $hrap_y );
print "Rainfall: $rainfall\n";

sub getrainfall {
	use Xbase;
	my $hrap_x = shift;
	my $hrap_y = shift;

	my $db = new Xbase;

	$db->open_dbf("last_24_hours.dbf");
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
	return ($rainfall );
}
