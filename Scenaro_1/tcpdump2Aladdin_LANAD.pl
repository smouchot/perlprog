#
use strict;
use Tk;
use Getopt::Std;
use lib qw(c:/cygwin/home/Stephane/perlprog/Scripts/lib);
use lib qw(c:/perlprog/Scripts/lib);
use Net::TcpDumpLog;

use Conversion;

getopts("t:c:v:h");

my $debug = 6;
# 7 pour xdh
# 5 pour les xhd

my $TCPDumpDir = ".\\";
my $TCPDumpFile = "tcpdump.cap";

my $OutputDir = ".\\";
my $OutputFile = "T_DAMB_";

# TCP parameters for FIM/FOM flow (serveur side)
my $FIMFOM_IP_Address = "200.1.18.15";
my $FIMFOM_TCP_Port = "1024";

# TCP parameters for XHD/XDH flow (server side)
my $XHD_IP_Address = "200.1.18.8";
my $XHD_TCP_Port = "31170";

# TCP parameters for SIMPLE flow (server side)
my $SIMPLE_IP_Address = "200.1.18.8";
my $SIMPLE_TCP_Port = "9002";

my $C4_SEND_IP_Address = "200.1.18.8";
my $C4_SEND_UDP_Port = "10452";

my $C4_RECEIVE_IP_Address = "200.1.8.1";
my $C4_RECEIVE_UDP_Port = "10402";

my $origin_seconds = 0;
my $origin_milli = 0;

if(my $opt_h){
	print "tcpdump2Aladdin.pl [-h] [-c test configuration] [-v version] [-t test name]\n";
	print "convertit un fichier tcpdump en fichier Aladdin...\n";
	exit -1;
}

if(! -f "$TCPDumpDir$TCPDumpFile"){
	print "$TCPDumpDir$TCPDumpFile does not exist !\n";
	exit -1;
}



my $mw = MainWindow->new;
$mw->title("$0"); 

my $Vframe1 = $mw->Frame->pack;
$Vframe1->Label(-text => "tcpdump2Aladdin.pl [-h] convertit un fichier tcpdump en fichiers Aladdin...\n")->pack(-side => 'left');
my $Vframe12 = $mw->Frame->pack;
$Vframe12->Label(-text => "Input directory : ")->pack(-side=>'left');
$Vframe12->Entry(-textvariable => \$TCPDumpDir, -width => 32, -borderwidth => 2)->pack(-side =>'left');
$Vframe12->Label(-text => 'TCPDump file : ')->pack(-side=>'left');
$Vframe12->Entry(-textvariable => \$TCPDumpFile, -width => 12, -borderwidth => 2)->pack(-side =>'left',	-padx => '5');
my $Vframe13 = $mw->Frame->pack;
$Vframe13->Label(-text => "Output directory : ")->pack(-side=>'left');
$Vframe13->Entry(-textvariable => \$OutputDir, -width => 32, -borderwidth => 2)->pack(-side =>'left');
$Vframe13->Label(-text => 'Output file : ')->pack(-side=>'left');
$Vframe13->Entry(-textvariable => \$OutputFile, -width => 12, -borderwidth => 2)->pack(-side =>'left',	-padx => '5');

my $Vframe2 = $mw->Frame->pack;
$Vframe2->Label(-text => "FIM/FOM  (server side) IP Address :")->pack(-side=>'left');
$Vframe2->Entry(-textvariable => \$FIMFOM_IP_Address, -width => 16, -borderwidth => 2)->pack(-side =>'left');
$Vframe2->Label(-text => 'TCP Port : ')->pack(-side=>'left');
$Vframe2->Entry(-textvariable => \$FIMFOM_TCP_Port, -width => 6, -borderwidth => 2)->pack(-side =>'left');
my $Vframe3 = $mw->Frame->pack;

$Vframe3->Label(-text => "XHD/XDH (server side) IP Address :")->pack(-side=>'left');
$Vframe3->Entry(-textvariable => \$XHD_IP_Address, -width => 16, -borderwidth => 2)->pack(-side =>'left');
$Vframe3->Label(-text => 'TCP Port : ')->pack(-side=>'left');
$Vframe3->Entry(-textvariable => \$XHD_TCP_Port, -width => 6, -borderwidth => 2)->pack(-side =>'left');

my $Vframe4 = $mw->Frame->pack;

$Vframe4->Label(-text => "SIMPLE (server side) IP Address :")->pack(-side=>'left');
$Vframe4->Entry(-textvariable => \$SIMPLE_IP_Address, -width => 16, -borderwidth => 2)->pack(-side =>'left');
$Vframe4->Label(-text => 'TCP Port : ')->pack(-side=>'left');
$Vframe4->Entry(-textvariable => \$SIMPLE_TCP_Port, -width => 6, -borderwidth => 2)->pack(-side =>'left');

my $Vframe5 = $mw->Frame->pack;
$Vframe5->Label(-text => "C4 SEND IP Address :              ")->pack(-side=>'left');
$Vframe5->Entry(-textvariable => \$C4_SEND_IP_Address, -width => 16, -borderwidth => 2)->pack(-side =>'left');
$Vframe5->Label(-text => 'UDP Port : ')->pack(-side=>'left');
$Vframe5->Entry(-textvariable => \$C4_SEND_UDP_Port, -width => 6, -borderwidth => 2)->pack(-side =>'left');

my $Vframe6 = $mw->Frame->pack;

$Vframe6->Label(-text => "C4 RECEIVE IP Address :           ")->pack(-side=>'left');
$Vframe6->Entry(-textvariable => \$C4_RECEIVE_IP_Address, -width => 16, -borderwidth => 2)->pack(-side =>'left');
$Vframe6->Label(-text => 'UDP Port : ')->pack(-side=>'left');
$Vframe6->Entry(-textvariable => \$C4_RECEIVE_UDP_Port, -width => 6, -borderwidth => 2)->pack(-side =>'left');

my $Vframe4 = $mw->Frame->pack;
my $ButtonExtract=$Vframe4->Button(-text=>'Extract',-state => 'active', -command => \&extract2Aladdin)->pack;

MainLoop;

sub extract2Aladdin {
	#$OutputDir = qw("$OutputDir");
	#$OutputFile = qw("$OutputFile");
	open FoutFIM, ">$OutputDir$OutputFile.fim" or die "Impossible ouvrir test.fim";
	open FoutFOM, ">$OutputDir$OutputFile.fom" or die "Impossible ouvrir test.fom";
	open FoutXHD, ">$OutputDir$OutputFile.xhd" or die "Impossible ouvrir test.xhd";
	open FoutXDH, ">$OutputDir$OutputFile.xdh" or die "Impossible ouvrir test.xdh";
	open FinSIMPLE, ">$OutputDir$OutputFile.so" or die "Impossible ouvrir test.so";
	open FoutSIMPLE, ">$OutputDir$OutputFile.si" or die "Impossible ouvrir test.si";
	open FinSIMPLEFIM, ">$OutputDir$OutputFile.SIMPLE.fim" or die "Impossible ouvrir test.fim";
	open FoutSIMPLEFOM, ">$OutputDir$OutputFile.SIMPLE.fom" or die "Impossible ouvrir test.fom";
	open FoutC4_SEND, ">$OutputDir$OutputFile.C4.xdh" or die "Impossible ouvrir test_C4.xdh";
	open FoutC4_RECEIVE, ">$OutputDir$OutputFile.C4.xhd" or die "Impossible ouvrir test_C4.xhd";
	my $log = Net::TcpDumpLog->new(32);	# force 32-bits to match this file
	$log->read("$TCPDumpDir$TCPDumpFile");

	my ($length_orig,$length_incl,$drops,$secs,$msecs) = $log->header(0);
	$origin_seconds = $secs;
	$origin_milli = $msecs;

	my @Indexes = $log->indexes;

	my $new_XDH = 1;
	my $new_XHD= 1;
	my $XDH = "";
	my $XHD = "";
	my $XDH_current_length = 0;
	my $XDH_length_in_char;
	my $XHD_length_in_char;
	my $XHD_current_length = 0;

	my $new_SIMPLE= 1;
	my $SIMPLE = "";
	my $SIMPLE_length_in_char;
	my $SIMPLE_current_length = 0;

	my $new_C4_SEND = 1;
	my $new_C4_RECEIVE= 1;
	my $C4_SEND = "";
	my $C4_RECEIVE = "";
	my $C4_SEND_current_length = 0;
	my $C4_RECEIVE_current_length = 0;
	my $C4_SEND_length_in_char;
	my $C4_RECEIVE_length_in_char;

	# Creation du fichier SIMPLE.conf
	open fout, ">$OutputDir$OutputFile.SIMPLE.conf" or die "Impossible ouvrir $OutputDir$OutputFile\n";
	#print fout "Host_Input_File=$OutputDir$OutputFile.xhd\n";
	#print fout "Host_Output_File=$OutputDir$OutputFile.xdh\n";
	print fout "Simple_Output_File = $OutputDir$OutputFile.so\n";
	print fout "Simple_Input_File = $OutputDir$OutputFile.si\n";
	close fout;

	# Creation du fichier FXM.conf
	open fout, ">$OutputDir$OutputFile.FXM.conf" or die "Impossible ouvrir $OutputDir$OutputFile\n";
	#print fout "Host_Input_File_1 = $OutputDir$OutputFile.xhd\n";
	#print fout "Host_Output_File_1 = $OutputDir$OutputFile.xdh\n";
	print fout "Link_Output_File_1 = $OutputDir$OutputFile.SIMPLE.fom\n";
	print fout "Link_Input_File_1 = $OutputDir$OutputFile.SIMPLE.fim\n";
	close fout;

		# Creation du fichier XHD.conf
	open fout, ">$OutputDir$OutputFile.XHD.conf" or die "Impossible ouvrir $OutputDir$OutputFile\n";
	#print fout "Host_Input_File_1 = $OutputDir$OutputFile.xhd\n";
	#print fout "Host_Output_File_1 = $OutputDir$OutputFile.xdh\n";
	print fout "Host_Output_File_1 = $OutputDir$OutputFile.xdh\n";
	print fout "Host_Input_File_1 = $OutputDir$OutputFile.xhd\n";
	print fout "Host_Output_File_2 = $OutputDir$OutputFile.C4.xdh\n";
	print fout "Host_Input_File_2 = $OutputDir$OutputFile.C4.xhd\n";
	close fout;

	foreach my $num  (0..$#Indexes){
	#foreach $num  (0..50){
		my ($length_orig,$length_incl,$drops,$secs_2,$msecs_2) = $log->header($num);
		my $zoneoffset = $log->zoneoffset();
		my $data = $log->data($num);
		my ($ether_dest,$ether_src,$ether_type,$ether_data) = getEtherParam($data);
		my $length = length($data);
		#print "$ether_dest,$ether_src,$ether_type,$ether_data\n";
		# si le paquet ethernet est un paquet IP	
		if( hex($ether_type) == 0x800) { 
			#print "$secs_2.$msecs_2\n";
			my ($secs, $msecs) = toRelative($secs_2, $msecs_2);
			my $chrono = "$secs.$msecs"if($msecs >99);
			$chrono = "$secs.0$msecs"if(100000 > $msecs && $msecs > 9999);
			$chrono = "$secs.00$msecs"if(10000 > $msecs && $msecs > 999);
			$chrono = "$secs.000"if($msecs < 99);
			#print "$chrono\n";
			#print "Mac src, Mac dest, Ether type , Ether length : 	$ether_dest, $ether_src, $ether_type, $length\n";
			my ($ip_type, $trash, $ip_total_length,$trash,$ip_proto, $trash, $ip_src1, $ip_src2, $ip_src3, $ip_src4, $ip_dest1, $ip_dest2, $ip_dest3, $ip_dest4, $ip_data) = getIPParam($ether_data);
			# Traitement protocole TCP
			if( hex($ip_proto) == 6) {
				$ip_total_length = hex($ip_total_length);
				my $ip_src = hex($ip_src1).".".hex($ip_src2).".". hex($ip_src3).".". hex($ip_src4);
				my $ip_dest = hex($ip_dest1).".".hex($ip_dest2).".".hex($ip_dest3).".".hex($ip_dest4);
				#print "$ip_data\n";
				#print "ip lentgh, ip src, ip dest  : $ip_total_length, $ip_src, $ip_dest\n";
				my ($tcp_port_src, $tcp_port_dest, $tcp_seq_num, $trash, $tcp_head_length) = unpack('H4H4H8H8H2a*', $ip_data);
				$tcp_port_src = hex($tcp_port_src);
				$tcp_port_dest = hex($tcp_port_dest);
				$tcp_head_length = int(hex($tcp_head_length)/16)*4;
				#print "tcp header lentgh, src port, dest port : $tcp_head_length, $tcp_port_src, $tcp_port_dest\n";
				my $length_tcp_head_in_byte = $tcp_head_length*2;
				my $data_length_in_byte = ($ip_total_length - 20 - $tcp_head_length)*2;
				if ($data_length_in_byte != 0) {
					my ($tcp_header, $tcp_data) = unpack ("H${length_tcp_head_in_byte}H${data_length_in_byte}", $ip_data);
					#print "tcp header  : $tcp_header\n";
					#print "tcp data    : $tcp_data\n" if (length($ip_data) > $tcp_head_length);
					print "$ip_src eq $XHD_IP_Address && $tcp_port_src eq $XHD_TCP_Port\n" if ($debug == 7);
					if($ip_src eq $XHD_IP_Address && $tcp_port_src eq $XHD_TCP_Port){
						#00:04:22.058 0000001D 01000079 0000 0329 0079 0100 2375 C20A 0000 000A 0100 0000 0000 0210 00
						#print "XDH:$secs.$msecs:$tcp_data\n";
						#print "Source :      $ip_src\t$tcp_port_src\n";
						#print "Destination : $ip_dest\t$tcp_port_dest\n";
						if($tcp_data =~/^4448(....)/ && $new_XDH == 1){
							#print "new XDH\n";
							$XDH=$tcp_data;
							$XDH_length_in_char = (hex($1)+4)*2;
							print "new XDH length in char = $XDH_length_in_char\n" if($debug == 7);
							$new_XDH = 0;
							<> if($debug == 7);
							#print "XDH:$XDH\n";
						}
						# Si l'on a trouv� le mot de synchro et qu'on n'est pas dans le 1er paquet
						if($tcp_data !~/^4448(....)/ && $new_XDH == 0){
							$XDH=$XDH.$tcp_data;
							print "XDH:$XDH\n" if ($debug == 7);
							<> if ($debug == 7);
						}
						# Calcul de la longueur courante du message
						$XDH_current_length = length($XDH);
						# Si la longueur est �gale et l'on a trouv� le mot de synchro 
						if($XDH_current_length == $XDH_length_in_char && $new_XDH == 0){
							$new_XDH = 1;
							$XDH=substr($XDH, 4, $XDH_length_in_char-4);
							$XDH =~s/^(.{4})(..)(.{6})/0000$1 01$3/;
							$XDH =~ s/\s//g;
							$XDH =~ s/(....)/$1 /g;
							$XDH =~ s/^(....) (....) (....) (....)/$1$2 $3$4/;
							# conversion minuscules en majuscules
							$XDH = uc ($XDH);
							my ($heure, $minute, $seconde, $milli) = conv2Time($chrono);
							print FoutXDH "$heure:$minute:$seconde.$milli $XDH\n";
							print "$heure:$minute:$seconde.$milli $XDH\n" if($debug == 7);
							<> if($debug == 7);
						}	
						# On memorise la longueur du message 
						# 
					}
					# Le paquet TCP est un XHD
					print "$ip_dest eq $XHD_IP_Address && $tcp_port_dest eq $XHD_TCP_Port\n" if ($debug == 5);
					if($ip_dest eq $XHD_IP_Address && $tcp_port_dest eq $XHD_TCP_Port){
						#print "XHD:$secs.$msecs:$tcp_data\n";
						#print "Source :      $ip_src\t$tcp_port_src\n";
						#print "Destination : $ip_dest\t$tcp_port_dest\n";
						# Si le paquet est le debut d'un message
						if($tcp_data =~/^4844(....)/ && $new_XHD == 1){
							#print "new XDH\n";
							$XHD=$tcp_data;
							$XHD_length_in_char = (hex($1)+4)*2;
							print "new XHD length in char = $XHD_length_in_char\n" if($debug == 5);
							<> if($debug == 5);
							#print "XDH:$XDH\n";
						}
						# Si le message est la continuation d'un message
						else{
							$XHD=$XHD.$tcp_data;
							#print "XDH:$XDH\n";
						}
						$XHD_current_length = length($XHD);
						if($XHD_current_length == $XHD_length_in_char){
							$new_XHD = 1;
							$XHD=substr($XHD, 4, $XHD_length_in_char-4);
							#print "$XHD\n";
							$XHD =~s/^(.{4})(..)(.{6})/0000$1 02$3 /;
							$XHD =~ s/\s//g;
							$XHD =~ s/(....)/$1 /g;
							$XHD =~ s/^(....) (....) (....) (....)/$1$2 $3$4/;
							# conversion minuscules en majuscules
							$XHD = uc($XHD);
							my ($heure, $minute, $seconde, $milli) = conv2Time($chrono);
							print FoutXHD "$heure:$minute:$seconde.$milli $XHD\n";
							print "$heure:$minute:$seconde.$milli $XHD\n" if($debug == 5);
							#<> if($debug == 5);
						}
					}
					# Le paquet TCP est un SIMPLE
					#print "$ip_dest eq $SIMPLE_IP_Address && $tcp_port_dest eq $SIMPLE_TCP_Port\n" if ($debug == 6);
					if(($ip_dest eq $SIMPLE_IP_Address && $tcp_port_dest eq $SIMPLE_TCP_Port)||($ip_src eq $SIMPLE_IP_Address && $tcp_port_src eq $SIMPLE_TCP_Port)) {
						#print "SIMPLE:$secs.$msecs:$tcp_data\n";
						#print "Source :      $ip_src\t$tcp_port_src\n";
						#print "Destination : $ip_dest\t$tcp_port_dest\n";
						# Si le paquet est le debut d'un message
						if($tcp_data =~/^4936(..)/ && $new_SIMPLE == 1){
							#print "new SIMPLE\n";
							$SIMPLE=$tcp_data;
							#print "$SIMPLE\n";
							$SIMPLE_length_in_char = hex($1)*2;
							#print "new SIMPLE length in char = $SIMPLE_length_in_char\n" if($debug == 6);
							#<> if($debug == 6);
							#print "SIMPLE:$SIMPLE\n";
							# Rajout d'une boucle pour traiter plusieurs messages
							while ((length($SIMPLE) >0) && ($SIMPLE_length_in_char <= length($SIMPLE))){
								my $SIMPLE_msg = substr($SIMPLE, 0, $SIMPLE_length_in_char);
								print "msg : $SIMPLE_msg\n";
								$SIMPLE = substr($SIMPLE, $SIMPLE_length_in_char );
								print "New msg $SIMPLE\n";
								my $FOM = decodeSIMPLEFOM($SIMPLE_msg);
								my $FIM = decodeSIMPLEFIM($SIMPLE_msg);
								print "$SIMPLE_msg\n";
								$SIMPLE_msg =~ /^(.{4})(..)(.{6})/;
								my $length = Conversion::toHexaString(hex($2)+4);
								print "$length\n";
								exit 0;
								$SIMPLE_msg =~ s/\s//g;
								$SIMPLE_msg =~ s/(....)/$1 /g;
								# conversion minuscules en majuscules
								$SIMPLE_msg = uc($SIMPLE_msg);
								#print "$chrono\n";
								my ($heure, $minute, $seconde, $milli) = conv2Time($chrono);
								if ($ip_dest eq $SIMPLE_IP_Address && $tcp_port_dest eq $SIMPLE_TCP_Port){
									print "FOM : $chrono,\n$FOM,\n$FIM,\n,$SIMPLE_msg\n";
									#<>;
									print FoutSIMPLEFOM "$heure:$minute:$seconde.$milli $FOM\n" if($FOM!= 0);
									print FoutSIMPLE "$heure:$minute:$seconde.$milli $length 1C000000 $SIMPLE_msg\n"if($FOM == 0);						
									print "$heure:$minute:$seconde.$milli $length 1C000000 $SIMPLE_msg\n" if($debug == 6);
								}
								else {
									print "FIM : $chrono,\n$FOM,\n$FIM,\n,$SIMPLE_msg\n";
									#<>;
									print FinSIMPLEFIM "$heure:$minute:$seconde.$milli $FIM\n" if($FIM!= 0);
									print FinSIMPLE "$heure:$minute:$seconde.$milli $length 1D000000 $SIMPLE_msg\n"if($FIM ==0);
									print "$heure:$minute:$seconde.$milli $length 1D000000 $SIMPLE_msg\n" if($debug == 6);
								}
							
								if($SIMPLE =~/^4936(..)/){
									$SIMPLE_length_in_char = hex($1)*2;
								}
								else{
									last;
								}
							}
							#<>  if($debug == 6);
						}
						# Si le message est la continuation d'un message
						else{
							$SIMPLE=$SIMPLE.$tcp_data;
							#print "SIMPLE:$SIMPLE\n";
						}
						$SIMPLE_current_length = length($SIMPLE);
						if($SIMPLE_current_length == $SIMPLE_length_in_char){
							$new_SIMPLE = 1;
							#$SIMPLE=substr($SIMPLE, $SIMPLE_length_in_char);
							print "$SIMPLE\n";
							$SIMPLE =~ /^(.{4})(..)(.{6})/;
							my $length = Conversion::toHexaString(hex($2)+4);
							$SIMPLE =~ s/\s//g;
							$SIMPLE =~ s/(....)/$1 /g;
							$SIMPLE =~ s/^(....) (....) (....) (....)/$1$2 $3$4/;
							# conversion minuscules en majuscules
							$SIMPLE = uc($SIMPLE);
							my ($heure, $minute, $seconde, $milli) = conv2Time($chrono);
							if ($ip_dest eq $SIMPLE_IP_Address && $tcp_port_dest eq $SIMPLE_TCP_Port){
								print FoutSIMPLE "$heure:$minute:$seconde.$milli $length 1C000000 $SIMPLE\n";
								print "toto $heure:$minute:$seconde.$milli $length 1C000000 $SIMPLE\n" if($debug == 6);
							}
							else {
								print FinSIMPLE "$heure:$minute:$seconde.$milli $length 1D000000 $SIMPLE\n";
								print "toto $heure:$minute:$seconde.$milli $length 1D000000 $SIMPLE\n" if($debug == 6);
							}
							#decodeSIMPLEHeader($SIMPLE);
							#<> if($debug == 6);
						}
						#<> if($debug == 6);
					}
					if($ip_src eq $FIMFOM_IP_Address && $tcp_port_src eq $FIMFOM_TCP_Port){
						#print "FOM:$secs.$msecs:$tcp_data\n";
						#print "Source :      $ip_src\t$tcp_port_src\n";
						#print "Destination : $ip_dest\t$tcp_port_dest\n";
						my $fom = fom2Aladdin($chrono, $tcp_data);
						print FoutFOM "$fom\n" if( $fom !~/^-1/);
						#print "$fom\n";
					}
					if($ip_dest eq $FIMFOM_IP_Address && $tcp_port_dest eq $FIMFOM_TCP_Port){
						#print "FIM:$secs.$msecs:$tcp_data\n";
						#print "Source :      $ip_src\t$tcp_port_src\n";
						#print "Destination : $ip_dest\t$tcp_port_dest\n";
						my $fim = fim2Aladdin($chrono, $tcp_data);
						print FoutFIM "$fim\n" if($fim !~/^-1/);
					}
				}
			}
			# Traitement protocole UDP
			if( hex($ip_proto) == 17){
				$ip_total_length = hex($ip_total_length);
				my $ip_src = hex($ip_src1).".".hex($ip_src2).".". hex($ip_src3).".". hex($ip_src4);
				my $ip_dest = hex($ip_dest1).".".hex($ip_dest2).".".hex($ip_dest3).".".hex($ip_dest4);
				#print "$ip_data\n";
				#print "ip lentgh, ip src, ip dest  : $ip_total_length, $ip_src, $ip_dest\n";
				my ($udp_port_src, $udp_port_dest, $udp_length, $udp_cksum, $udp_data) = unpack('H4H4H4H4a*', $ip_data);
				$udp_port_src = hex($udp_port_src);
				$udp_port_dest = hex($udp_port_dest);
				#print "udp port src, port dst : $udp_port_src, $udp_port_dest\n";
				my $data_length_in_byte = hex($udp_length) - 8;
				print "udp data length in byte : $data_length_in_byte \n" if($debug == 3);
				if ($data_length_in_byte != 0) {
					my $data_length_in_char = $data_length_in_byte * 2;
					print "$ip_src -> $C4_SEND_IP_Address $udp_port_src -> $C4_SEND_UDP_Port\n"if($debug == 3);
					if($ip_src eq $C4_SEND_IP_Address && $udp_port_src eq $C4_SEND_UDP_Port){
						my $udp_data = unpack ("H${data_length_in_char}", $udp_data);
						#00:04:22.058 0000001D 01000079 0000 0329 0079 0100 2375 C20A 0000 000A 0100 0000 0000 0210 00
						print "C4 SEND : $secs.$msecs:$udp_data\n"if($debug == 3);
						#print "Source :      $ip_src\t$udp_port_src\n";
						#print "Destination : $ip_dest\t$udp_port_dest\n";
						if($udp_data =~/^4448(....)/ && $new_C4_SEND == 1){
							#print "new XDH\n";
							$C4_SEND=$udp_data;
							$C4_SEND_length_in_char = (hex($1)+4)*2;
							print "new C4 SEND length in char = $C4_SEND_length_in_char\n" if($debug == 3);
							<> if($debug == 3);
							#print "C4 SEND:$C4_SEND\n";
							$new_C4_SEND = 0;
						}
						else{
							$C4_SEND=$C4_SEND.$udp_data;
							#print "XDH:$XDH\n";
						}
						$C4_SEND_current_length = length($C4_SEND);
						print "Current length : $C4_SEND_current_length\n" if($debug == 3);
						if($C4_SEND_current_length == $C4_SEND_length_in_char && $new_C4_SEND == 0){
							$new_C4_SEND = 1;
							$C4_SEND=substr($C4_SEND, 4, $C4_SEND_length_in_char-4);
							$C4_SEND =~s/^(.{4})(..)(.{6})/0000$1 01$3 /;
							# conversion minuscules en majuscules
							$C4_SEND = uc($C4_SEND);
							my ($heure, $minute, $seconde, $milli) = conv2Time($chrono);
							print FoutC4_SEND "$heure:$minute:$seconde.$milli $C4_SEND\n";
							print "$heure:$minute:$seconde.$milli $C4_SEND\n" if($debug == 3);
							<> if($debug == 3);
						}	
						# On memorise la longueur du message 
						# 
					}
					print "$ip_dest -> $C4_RECEIVE_IP_Address $udp_port_dest -> $C4_RECEIVE_UDP_Port\n" if ($debug == 2);
					if($ip_src eq $C4_RECEIVE_IP_Address && $udp_port_dest eq $C4_SEND_UDP_Port){
						my $udp_data = unpack ("H${data_length_in_char}", $udp_data);
						print "C4 RECEIVE  :$secs.$msecs:$udp_data\n" if($debug == 2);
						#print "Source :      $ip_src\t$tcp_port_src\n";
						#print "Destination : $ip_dest\t$tcp_port_dest\n";
						if($udp_data =~/^4844(....)/ && $new_C4_RECEIVE == 1){
							#print "new C4_RECEIVE\n";
							$C4_RECEIVE=$udp_data;
							$C4_RECEIVE_length_in_char = (hex($1)+4)*2;
							print "new C4 RECEIVE length in char = $C4_RECEIVE_length_in_char\n" if($debug == 2);
							<> if($debug == 2);
							$new_C4_RECEIVE = 0;
							#print "C4 RECEIVE:$C4_RECEIVE\n";
						}
						else{
							$C4_RECEIVE=$C4_RECEIVE.$udp_data;
						}
						$C4_RECEIVE_current_length = length($C4_RECEIVE);
						print "Current length : $C4_RECEIVE_current_length\n" if($debug == 2);
						if($C4_RECEIVE_current_length == $C4_RECEIVE_length_in_char && $new_C4_RECEIVE == 0 ){
							$new_C4_RECEIVE = 1;
							$C4_RECEIVE=substr($C4_RECEIVE, 4, $C4_RECEIVE_length_in_char-4);
							$C4_RECEIVE =~s/^(.{4})(..)(.{6})/0000$1 02$3 /;
							# conversion minuscules en majuscules
							$C4_RECEIVE = uc($C4_RECEIVE);
							my ($heure, $minute, $seconde, $milli) = conv2Time($chrono);
							print FoutC4_RECEIVE "$heure:$minute:$seconde.$milli $C4_RECEIVE\n";
							print "$heure:$minute:$seconde.$milli $C4_RECEIVE\n" if($debug == 2);
							<> if($debug == 2);
						}
					}
				}
			}
		}

	}
	close FoutFIM;
	close FoutFOM;
	close FoutXHD;
	close FoutXDH;
	close FoutC4_SEND;
	close FoutC4_RECEIVE;
	close FoutSIMPLE;
	close FinSIMPLE;
	close FinSIMPLEFIM;
	close FoutSIMPLEFOM;
	return 0;
}

sub getEtherParam{
	my $data = shift;
	my ($ether_dest,$ether_src,$ether_type,$ether_data) = unpack('H12H12H4a*',$data);
	return ($ether_dest,$ether_src,$ether_type,$ether_data);
}

sub getEtherData{
}

sub getIPParam{
	my $data = shift;
	my ($ip_type, $trash, $ip_total_length,$trash,$ip_proto, $trash, $ip_src1, $ip_src2, $ip_src3, $ip_src4, $ip_dest1, $ip_dest2, $ip_dest3, $ip_dest4, $ip_data) = unpack('H2H2H4H10H2H4H2H2H2H2H2H2H2H2a*', $data);
	return ($ip_type, $trash, $ip_total_length,$trash,$ip_proto, $trash, $ip_src1, $ip_src2, $ip_src3, $ip_src4, $ip_dest1, $ip_dest2, $ip_dest3, $ip_dest4, $ip_data);
}

sub getIPData{
}

sub getTCPParam{
	my $data = shift;
	my ($tcp_port_src, $tcp_port_dest, $tcp_seq_num, $trash, $tcp_head_length) = unpack('H4H4H8H8H2a*', $data);
	return ($tcp_port_src, $tcp_port_dest, $tcp_seq_num, $trash, $tcp_head_length);
}
	

sub toRelative{
	my $secs = shift;
	my $msecs = shift;
	#print "$origin_seconds:$origin_milli\n";
	if ($msecs < $origin_milli) {
		$msecs = 1000000 + $msecs - $origin_milli ;
		$secs = $secs - $origin_seconds -1;
	}
	else {
		$msecs = $msecs - $origin_milli;
		$secs = $secs - $origin_seconds;
	}
	return ($secs, $msecs);
}
sub fom2Aladdin {
	my $Fom1MsgHeader = "04000001";
	my $time = shift;
	#print "time : $time\n";
	my $fom = shift;
	if($fom =~ /(..)(..)(.*)\s*/){
		my ($heure_e, $minute_e, $seconde_e, $milli_e) = conv2Time($time);
		#print " heure emission : $heure_e, $minute_e, $seconde_e\n";
		my $BXM1 = $1;
		my $BXM2 = $2;
		#print "BXM1 : $BXM1\n";
		#print "BXM2 : $BXM2\n";
		my $FXM=$3;
		# suppresion des blancs
		$FXM =~ s/\s//g;
		# s�paration par paire d'octet XXXX XXXX ...
		$FXM =~ s/(....)/$1 /g;;
		if($BXM1 =~ /82/){
		  # Calcul de la longueur du FXM
		  my $lengthFxm = hex($BXM2);
		  # Calcul de la longueur du message Aladdin
		  $lengthFxm = $lengthFxm*2+4;
		  $lengthFxm = Conversion::toHexaString($lengthFxm);
		  # formattage des secondes ss.mmm
		  $fom = "$heure_e:$minute_e:$seconde_e.$milli_e $lengthFxm $Fom1MsgHeader $FXM";
		  return $fom;
	  	}
		else {
			$fom = "-1";
			return $fom;
		}
  	}
}	      
	
sub fim2Aladdin {
	my $Fim1MsgHeader = "06000001";
	my $time = shift;
	#print "time : $time\n";
	my $fim = shift;
	if($fim =~ /(..)(..)(.*)\s*/){
		my ($heure_e, $minute_e, $seconde_e, $milli_e) = conv2Time($time);
		#print " heure emission : $heure_e, $minute_e, $seconde_e\n";
		my $BXM1 = $1;
		my $BXM2 = $2;
		#print "BXM1 : $BXM1\n";
		#print "BXM2 : $BXM2\n";
		my $FXM=$3;
		# suppresion des blancs
		$FXM =~ s/\s//g;
		# s�paration par paire d'octet XXXX XXXX ...
		$FXM =~ s/(....)/$1 /g;
		#print "$FXM\n";
		#print "C'est un FIM \n";
		if($BXM1 =~ /82/){
		  #print "C'est un FIM01 \n";
		  # Calcul de la longueur du FXM
		  my $lengthFxm = hex($BXM2);
		  # Calcul de la longueur du message Aladdin
		  $lengthFxm = $lengthFxm*2+4;
		  $lengthFxm = Conversion::toHexaString($lengthFxm);
		  # formattage des secondes ss.mmm
		  $fim = "$heure_e:$minute_e:$seconde_e.$milli_e $lengthFxm $Fim1MsgHeader $FXM";
		  return $fim;
		}	
		else{
			$fim = "-1";
			return $fim;
		}
	}
}

sub conv2Time {
	my $chrono = shift;
	my $milli = 0;
	#print "chron : $chrono \n";
	my $heure = int $chrono/3600;
	#print "$heure\n";
	my $minute = int (($chrono - ($heure*3600))/60);	
	my $seconde = $chrono - ($heure*3600) - ($minute *60);
	#print "$heure $minute $seconde\n";
	$milli = int(($seconde-int($seconde))*1000);
	$seconde = int( $seconde);
	#print "$heure $minute $seconde $milli\n";
	$heure = substr('0'.$heure, -2);
	#print "$heure\n";
	$minute = substr('0'.$minute, -2);
	#print "$minute\n";
	$seconde = substr('0'.$seconde, -2);
	$milli = substr('00'.$milli, -3);
	#print "$heure $minute $seconde $milli\n";
	return ($heure, $minute, $seconde, $milli);
}

sub decodeSIMPLEFOM {
	my $Line = shift;
	#print "$Line\n";
		#$Line = s/\s//g;
	$Line =~ s/(..)/$1 /g;
	#print "$Line\n";
		my @Entete = split (" ",$Line);
		print "Sync : $Entete[0]$Entete[1]\n";
		my $Length = "$Entete[3]"."$Entete[2]";
		#print "$Length\n";		
		$Length = hex($Length);
		print "Length = $Length\n";
		my $Seq_number = "$Entete[5]"."$Entete[4]";
		$Seq_number = hex ($Seq_number);
		print "Seq_number = $Seq_number\n";
		my $Source_node = hex($Entete[6]);
		print "Source node = $Source_node\n";
		my $Source_sub_node = hex($Entete[7]);
		print "Source subnode = $Source_sub_node\n";
		my $Dest_node = hex($Entete[8]);
		print "Dest node = $Dest_node\n";
		my $Dest_sub_node = hex($Entete[9]);
		print "Dest_sub_node = $Dest_sub_node\n";
		my $Packet_size = hex($Entete[10]);	
		print "Packet size = $Packet_size\n";
		my $Packet_type = hex($Entete[11]);
		print "Packet type = $Packet_type\n";
		my$Transit_time = "$Entete[13]"."$Entete[12]";
		$Transit_time = hex($Transit_time);
		print "Transmit time = $Transit_time\n";
		if($Packet_type == 1){
			$Line =~ s/\s*//g;
			my $Packet_header_data = substr($Line, 28);
			print "$Line\n$Packet_header_data\n";
			my $Msg_sub_type = hex(substr($Packet_header_data,0,2));
		  	print "\tMsg_sub_type = $Msg_sub_type\n";
		  	my $RC_flag= hex(substr($Packet_header_data,2,2));
		  	print "\tRC_flag = $RC_flag\n";
		  	my $Net_number= hex(substr($Packet_header_data,4,2));
		  	print "\tNet_number= $Net_number\n";
		  	my $Seq_slot_count_field_2= hex(substr($Packet_header_data,6,2));
		  	print "\tSeq_slot_count_field_2 = $Seq_slot_count_field_2\n";
		  	my $NPG_number = hex(substr($Packet_header_data,10,2).substr($Packet_header_data,8,2));
		  print "\tNPG_number = $NPG_number\n";
		  my $Seq_slot_count_field_1= hex(substr($Packet_header_data,14,2).substr($Packet_header_data,12,2));
		  print "\tSeq_slot_count_field_1 = $Seq_slot_count_field_1\n";
		  my $STN= hex(substr($Packet_header_data,18,2).substr($Packet_header_data,16,2));
		  print "\tSTN = $STN\n";
		  my $Word_count= hex(substr($Packet_header_data,22,2).substr($Packet_header_data,20,2));
		  print "\tWord_count = $Word_count\n";
		  my $Loopback_id= hex(substr($Packet_header_data,26,2).substr($Packet_header_data,24,2));
		  print "\tLoopback_id = $Loopback_id\n";
		  my $Msg_data= substr($Packet_header_data,28);
		  print "\tMsg_data = $Msg_data\n";
		  $Msg_data =~ s/(....)$//;

		  if($Msg_sub_type == 2){
		    # espacement par mot de 16 bit
		    $Msg_data =~ s/(....)/$1 /g;
		    #print "\t\t$Msg_data\n";
		    # inversion des octets par mot de 16 bit
		    $Msg_data =~ s/(\S\S)(\S\S)\s/$2$1 /g;
		    #print "\t\t$Msg_data\n";
		    my $lengthFxm = $Word_count*2+4+10;
		    my $lengthFxm = Conversion::toHexaString($lengthFxm);
		    my $STN = substr(Conversion::toHexaString($STN),-4);
		    my $NPG_number_high =  substr(Conversion::toHexaString($NPG_number),-4,2);
	            my $NPG_number_low = substr(Conversion::toHexaString($NPG_number),-2,2);
		    my $Msg_data= "0000 $STN $NPG_number_low$NPG_number_high 0000 0000"." $Msg_data";
		    #print "\t\t$Msg_data\n";
			$Msg_data = "$lengthFxm 04000001 $Msg_data\n";
			return $Msg_data;
		  }
		  else {
			return 0;
		}
	}
	else {
		return 0;
	}
}


sub decodeSIMPLEFIM {
	my $Line = shift;
	#print "$Line\n";
		#$Line = s/\s//g;
	$Line =~ s/(..)/$1 /g;
	#print "$Line\n";
		my @Entete = split (" ",$Line);
		print "Sync : $Entete[0]$Entete[1]\n";
		my $Length = "$Entete[3]"."$Entete[2]";
		#print "$Length\n";		
		$Length = hex($Length);
		print "Length = $Length\n";
		my $Seq_number = "$Entete[5]"."$Entete[4]";
		$Seq_number = hex ($Seq_number);
		print "Seq_number = $Seq_number\n";
		my $Source_node = hex($Entete[6]);
		print "Source node = $Source_node\n";
		my $Source_sub_node = hex($Entete[7]);
		print "Source subnode = $Source_sub_node\n";
		my $Dest_node = hex($Entete[8]);
		print "Dest node = $Dest_node\n";
		my $Dest_sub_node = hex($Entete[9]);
		print "Dest_sub_node = $Dest_sub_node\n";
		my $Packet_size = hex($Entete[10]);	
		print "Packet size = $Packet_size\n";
		my $Packet_type = hex($Entete[11]);
		print "Packet type = $Packet_type\n";
		my$Transit_time = "$Entete[13]"."$Entete[12]";
		$Transit_time = hex($Transit_time);
		print "Transmit time = $Transit_time\n";
		if($Packet_type == 1){
			$Line =~ s/\s*//g;
			my $Packet_header_data = substr($Line, 28);
			print "$Line\n$Packet_header_data\n";
			my $Msg_sub_type = hex(substr($Packet_header_data,0,2));
		  	print "\tMsg_sub_type = $Msg_sub_type\n";
		  	my $RC_flag= hex(substr($Packet_header_data,2,2));
		  	print "\tRC_flag = $RC_flag\n";
		  	my $Net_number= hex(substr($Packet_header_data,4,2));
		  	print "\tNet_number= $Net_number\n";
		  	my $Seq_slot_count_field_2= hex(substr($Packet_header_data,6,2));
		  	print "\tSeq_slot_count_field_2 = $Seq_slot_count_field_2\n";
		  	my $NPG_number = hex(substr($Packet_header_data,10,2).substr($Packet_header_data,8,2));
		  print "\tNPG_number = $NPG_number\n";
		  my $Seq_slot_count_field_1= hex(substr($Packet_header_data,14,2).substr($Packet_header_data,12,2));
		  print "\tSeq_slot_count_field_1 = $Seq_slot_count_field_1\n";
		  my $STN= hex(substr($Packet_header_data,18,2).substr($Packet_header_data,16,2));
		  print "\tSTN = $STN\n";
		  my $Word_count= hex(substr($Packet_header_data,22,2).substr($Packet_header_data,20,2));
		  print "\tWord_count = $Word_count\n";
		  my $Loopback_id= hex(substr($Packet_header_data,26,2).substr($Packet_header_data,24,2));
		  print "\tLoopback_id = $Loopback_id\n";
		  my $Msg_data= substr($Packet_header_data,28);
		  print "\tMsg_data = $Msg_data\n";
		  $Msg_data =~ s/(....)$//;

		  if($Msg_sub_type == 2){
		    # espacement par mot de 16 bit
		    $Msg_data =~ s/(....)/$1 /g;
		    #print "\t\t$Msg_data\n";
		    # inversion des octets par mot de 16 bit
		    $Msg_data =~ s/(\S\S)(\S\S)\s/$2$1 /g;
		    #print "\t\t$Msg_data\n";
		    my $lengthFxm = $Word_count*2+4+16;
		    my $lengthFxm = Conversion::toHexaString($lengthFxm);
		    my $STN = substr(Conversion::toHexaString($STN),-4);
		    my $NPG_number_high =  substr(Conversion::toHexaString($NPG_number),-4,2);
	            my $NPG_number_low = substr(Conversion::toHexaString($NPG_number),-2,2);
		    my $Msg_data= "0000 0000 0000 0000 0000 0000 $NPG_number_low$NPG_number_high $STN"." $Msg_data";
		    #print "\t\t$Msg_data\n";
			$Msg_data = "$lengthFxm 06000001 $Msg_data\n";
			return $Msg_data;
		  }
		  else {
			return 0;
		}
	}
	else {
		return 0;
	}
}


