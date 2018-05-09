    #!/usr/bin/perl -w
    use strict;
    use IO::Socket;
    my ($host, $port, $kidpid, $handle, $line, $byte);

    unless (@ARGV == 2) { die "usage: $0 host port" }
    ($host, $port) = @ARGV;
	#($host, $port) = ("localhost", 2345);
    # create a tcp connection to the specified host and port
    while(1){
    	print "Try to connect to server $host on port $port\n";
    	sleep 1;
    	eval {
    		$handle = IO::Socket::INET->new(Proto     => "tcp",
                                    PeerAddr  => $host,
                                    PeerPort  => $port)
        	or die "can't connect to port $port on $host: $!";
    	};
    	next if($@ =~ /can't connect/);

    	$handle->autoflush(1);       # so output gets there right away
    	print STDERR "[Connected to $host:$port]\n";

    	# split the program into two processes, identical twins
    	die "can't fork: $!" unless defined($kidpid = fork());

    	# the if{} block runs only in the parent process
    	if ($kidpid) {
        	# copy the socket to standard output
        	while (1){
        		eval{
        			my $byte1;
        			$byte = read($handle, $byte1, 1) or die "no read";
        			#print "$byte1\n";
        			process_rxdata($byte);
        			syswrite STDOUT,  $byte1;
        		};
        		last if($@ =~ /no read/);
        	}
        	kill("TERM", $kidpid);   # send SIGTERM to child
    	}
    	# the else{} block runs only in the child process
    	else {
    		my $i = 0;
        	# copy standard input to the socket
        	while (1){
        		$line = "Ici client from port $port $i\n";
        		$i += 1;
            	print $handle $line;
            	sleep 3;
        	}
        	exit(0);                # just in case
    	}
    }
    
    sub process_rxdata(){
    	my $byte = shift;
    	
    }