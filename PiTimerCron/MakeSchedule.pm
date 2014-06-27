package MakeSchedule;

use strict;
use Exporter;
use Data::Dumper;

our @ISA = qw( Exporter );
our @EXPORT = qw( MakeSchedule );

sub MakeSchedule {
	use XML::LibXML;
	
	localtime() =~ /^(...).*(\d\d):(\d\d):(\d\d)/;	#"Thu Oct 13 04:54:34 1994"
	my $day     = $1;
	my $CurTime = $2 * 60 + $3;
	my $today = sprintf( "%4d-%02d-%02d",
		(localtime)[5] + 1900,
		(localtime)[4] + 1,
		(localtime)[3] );
	my @DayList = qw( Sun Mon Tue Wed Thu Fri Sat );
	my %Schedule = (
	        Sun => {},
	        Mon => {},
	        Tue => {},
	        Wed => {},
	        Thu => {},
	        Fri => {},
	        Sat => {}
	);
	
	my $ratio = 1.0;
	
	open( INFO, "/var/www/PiTimer/evapadj.txt" );
	while ( my $line = <INFO> ) {
		if ( $line =~ /^Ratio: (.*)%$/ ) {
			$ratio = $1/100;
			#print "$ratio\n";
		}
	}
	close INFO;
	
	my $parser = XML::LibXML->new();
	
	my $PiTimer = $parser->parse_file('/var/www/PiTimer/PiTimer.xml');
	foreach my $program ( $PiTimer->findnodes('PiTimer/Schedule/Program') ) {
		if ( my $date = $program->findvalue('./Date') ) {
			if ( $date eq $today ) {
				$program->findvalue('./StartTime') =~ /^(\d+):(\d+):(\d+)$/;
				my $StartTime = $1 * 60 + $2;
				foreach my $timer ( $program->findnodes('./Timer') ) {
					my $zone = $timer->getAttribute('ZoneID');
					my $RunTime =$timer->textContent+.5;
					#print "Zone: $zone RunTime: $RunTime\n";
					for my $i ( 1 .. $RunTime ) {
						while ( defined( $Schedule{$day}{$StartTime} ) ) {
							$StartTime += 1;
							if ( $StartTime > 24 * 60 ) {
								die("Cannot schedule past midnight $day\n");
							}
						}
						$Schedule{$day}{$StartTime} = $zone;
					}
				}
			}
		}else {
			foreach my $days ( $program->findnodes('./Day') ) {
				my $ProgDay=$days->findvalue('.');
				$program->findvalue('./StartTime') =~ /^(\d+):(\d+):(\d+)$/;
				my $StartTime = $1 * 60 + $2;
				#print "$StartTime\n";
				foreach my $timer ( $program->findnodes('./Timer') ) {
					my $zone = $timer->getAttribute('ZoneID');
					my $RunTime =int($ratio*$timer->textContent+.5);
					#print "Zone: $zone RunTime: $RunTime\n";
					for my $i ( 1 .. $RunTime ) {
						while ( defined( $Schedule{$ProgDay}{$StartTime} ) ) {
							$StartTime += 1;
							if ( $StartTime > 24 * 60 ) {
								die("Cannot schedule past midnight $ProgDay\n");
							}
						}
						$Schedule{$ProgDay}{$StartTime} = $zone;
					}
				}
			}
		}
	}
	return %Schedule;
}

1;
