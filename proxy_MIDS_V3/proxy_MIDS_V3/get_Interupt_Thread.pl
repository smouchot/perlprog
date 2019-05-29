#!/usr/bin/perl -w

use Thread;

$SIG{INT} = \&got_int;
$SIG{ALRM} = sub { die "timeout" };
my $kidAlive = 0;
my $fom03Present :shared;
#share($fom03Present);
$fom03Present = 1;

Thread->new(\&DLIP2MIDS);
# Le thread parent

while(1){
	print "kidpid1 : start\n";
	eval {
		alarm(3);		    
	    print "waiting 3s...\n";
	    sleep 10;
	    alarm(0);
	};
	if ($@ =~ /timeout/) {
    	print "check FOM03\n";
    	$fom03Present = 0;		                            # timed out; do what you will here
		print "timeout 3s\n";
	}
    else {
        alarm(0);           # clear the still-pending alarm
        die;                # propagate unexpected exception
    } 
    alarm(0);	
}
 
sub DLIP2MIDS {
	my $kidAlive = 0;
	while(1){		
		if (! $kidAlive){
			$fom03Present = 1;
			my $th = Thread->new(\&MIDS2DLIP);
			print "start th2 $th\n";
			$fom03Present = 1;
			$kidAlive = 1;
			
		}		
		while(1){
			print "fom03 present ? $fom03Present\n";				
			if($fom03Present){
				# on lit la socket
				print "reading socket\n";
			}
			else{
				# on ferme la socket
				# on tue le fils
				print "kill kid\n";
				#kill 9 => $kidpid;
				$kidAlive = 0;
				#exit;
				# on ouvre une nouvelle socket
				last;
			}
			sleep 1;				
		}
	}
}

sub MIDS2DLIP{
	my $time = 0 ;
	while(1){
		if($fom03Present){
			print "still living...\n";
			print "it is $time\n";
			sleep 1;
			$time += 1;		
		}
		else{
			print "fom03 absent exit\n";
			last;
		}
	}
}

sub got_int {
	print " I'm got interrupt, bye !\n";
	exit 0;
}