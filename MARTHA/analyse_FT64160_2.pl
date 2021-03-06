#!/usr/bin/perl -w
# genere des fichiers .cvs avec 
# l'�tat de staturation du MIDS 0/1
# l'�tat du DLIP
# l'envoi du TDH029
# les TX oppotunite
# les J transmis selon priorit� (?)

use strict;
use Getopt::Std;

#use lib qw(c:/cygwin/home/Stephane/perlprog/Scripts/lib);
#use lib qw(c:/perlprog/lib);
use lib qw(D:\Users\t0028369\perlprog\lib);
use Conversion;
use J_Msg;
use Time_conversion;
use File::Basename;

my $inFileName = $ARGV[0];
print "$ARGV[0]\n";
#exit;

my $outFileName1 = "extract_MIDS_Saturation_State.csv";

my $line;
my $result;
my $chrono = 0000.00;
my $time = "00:00:00.000";
my $midsStatus1 = 0;
my $dlipStatus1 = 0;
my $tdh0291 = 0;
my $midsStatus2 = 0;
my $dlipStatus2 = 0;
my $tdh0292 = 0;
my $tx_opp_1 = 0;
my $tx_j_1 = 0;
my $tx_j_hostile_1 = 0;
my $tx_j_suspect_1 = 0;
my $tx_opp_2 = 0;
my $tx_j_2 = 0;
my $tx_j_hostile_2 = 0;
my $tx_j_suspect_2 = 0;
my $saturation_state = 0;

open Fin, "<$inFileName" or die "impossible open $inFileName ....\n";
open Fout1, ">$outFileName1" or die "impossible open $outFileName1 ....\n";
open Flog, ">extract_Needline.log" or die "extract_Needline.log";

print Fout1 "Chrono;Saturation\n";
print Flog "log\n";


 my $event = 1;
 


while(<Fin>){
	$line = $_;
	chomp $line;
	print "$line\n";
	

	if ($line =~ /^MARTHA :\s\++\s+(\d+\.\d+)/){
		$chrono = $1;
		
		$time = Conversion::toTime($chrono);
		print "$time\n";
		$chrono =~ s/\./,/;
		print "$chrono\n";
		
	}
	else {
		next;
	}	
	if ($line =~ /ANALYSE_MIDS_TX_QUEUES_STATUS/){
		if($line =~/Uncontrolled PGs in saturation state/ || $line =~ /Status = SATURATED/){
				$saturation_state = 1;
		}
		if($line =~/Status = NOT_SATURATED/){
			$saturation_state = 0;
		}
		printFout1();
	}

}

close Fin;
close Fout1;
close Flog;

sub printFout1 {
	print Fout1 "$chrono;$saturation_state\n";	
}

exit 0;