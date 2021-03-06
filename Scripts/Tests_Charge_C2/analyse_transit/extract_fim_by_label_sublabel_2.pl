#!/usr/bin/perl -w

# Affaire : SAMPT
# T�che : mesure du temps de travers�e
# Auteur : S. Mouchot
# Mis � jour : le 23/05/2006
# Description :
# le script extrait du fichier .fim d'entree dans un fichier texte $RESULT_FILE
# contenant les infos suivantes dans les fichiers texte correspondants :
# exemple :
# pour les j3_0
# 00:24:51.993 PLAT_0003
# pour les j3_2
# 00:24:51.993 IFF_0033
# pour les j3_7
# 00:25:00.192 ID_0000
# La valeur de l'IFF est affich�e en octal

use Getopt::Std;

my @MOT;
my $RESULTS_FILE = "fim_arrival_times_and_tns.txt";
 my $Old_word = "0000";
my $SuppDoublon = 1;

getopts("hf:o:");

my $Offset_motI=11; # offset du mot I dans le tableau @MOT $MOT[11] est le 1er boctet
sub getJValue {
	my $Bit_offset = shift; # compris entre 0 et 79
	my $Bit_number = shift; # compris entre 1 et 80
	# Calcul des boctets utiles
	my $First_boctet = int($Bit_offset/16);
	my $Last_boctet = int(($Bit_offset+$Bit_number)/16);
	my $First_bit_of_first_boctet = $Bit_offset%16;
	my $Last_bit_of_last_boctet = ($Bit_offset+$Bit_number)%16;
	my $String = getBoctetHexaString($Last_boctet);
	$String = toHexaString(maskBoctetLastBit($String, $Last_bit_of_last_boctet));
	if($Last_boctet>$First_boctet){
		for $I (($Last_boctet-1).. $First_boctet) {
		$String = $String . getBoctetHexaString($I);
		}
	}
	my $JValue = int(hex($String)/(2**$First_bit_of_first_boctet));
	#print "Jvalue : $JValue\n";
	return $JValue;
}

sub getBoctetHexaString {
	my $Boctet_number = shift;
	my $Boctet_index = getIndexforBoctet($Boctet_number);
	my $String = $MOT[$Boctet_index];
	#print "BoctetHexaString : $String\n";
	return $String;
}

sub getIndexforBoctet {
	my $Boctet_number = shift;
	my $IndexforBoctet = $Offset_motI + $Boctet_number;
	#print "index : $IndexforBoctet\n";
	return $IndexforBoctet;
}

sub toHexaString {
    my@tab = (0..9,A..F);
    my $string = "";
    my $nbre = shift;
    #print "$nbre : ";
    if ($nbre == 0) {
	$string = "00000000";
    }
    else {
	while ($nbre>0) {
	    my $i = $nbre%16;
	    $string = $tab[$i].$string;
	    $nbre = int($nbre/16);
	}
    }
    $string = substr("0000000000"."$string", -8, 8);
    #print "hexa : $string \n";
    return $string;
}
sub toOctalString {
    my@tab = (0..7);
    my $string = "";
    my $nbre = shift;
    #print "$nbre : ";
    if ($nbre == 0) {
	$string = "0000";
    }
    else {
	while ($nbre>0) {
	    my $i = $nbre%8;
	    $string = $tab[$i].$string;
	    $nbre = int($nbre/8);
	}
    }
    $string = substr("0000"."$string", -4, 4);
    #print "Octal : $string \n";
    return $string;
}

sub getIndexBoctetMotI {
	my $Position_Mot_I = 8;
	my $BIT_Position = shift;
	return 14-int($BIT_Position/16);
}
sub maskBoctetLastBit {
	my $Boctet = shift;
	my $Last_bit_position = shift;
	#print "$Boctet : $Last_bit_position\n";
	my $Mask = (2**($Last_bit_position))-1;
	my $Boctet_value = hex($Boctet) & $Mask;
	#print "$Mask : $Boctet_value \n";
	return $Boctet_value;
}

if ($opt_h) { 
  print "extract_TN_date_from_fim.pl -f nom_fichier : extrait";
  exit(0);
}
if( ! $opt_h && $opt_f) {
	my $fichierInput = "$opt_f";
	my $fichierOutput = "fim_J2_0.txt";

	open Fin, "<$fichierInput" or die "impossible d'ouvrir le fichier d'entree $fichierInput \n";
	open Fout, ">$fichierOutput" or die "impossible d'ouvrir le fichier de sortie $fichierOutput \n";
	print "Extract from $fichierInput to $fichierOutput, please wait...\n";	
	
	while(<Fin>){
		chomp;
		my $LIGNE = $_;
		@MOT = split " ",$LIGNE;
		#print "$MOT[14]\n";
		# Recherche du label et du sublabel
		my $Label_bit_offset=2;
		my $Label_bit_number=5;
		my $Label = getJValue($Label_bit_offset, $Label_bit_number);
		my $Sublabel_bit_offset=7;
		my $Sublabel_bit_number=3;
		my $Sublabel = getJValue($Sublabel_bit_offset, $Sublabel_bit_number);
		print "Label : $Label SubLabel : $Sublabel\n";
		#my $Length_fxm = scalar @MOT;
		#print "Length_fxm = $Length_fxm\n";
		if($Label == 10 && $Sublabel == 2 ){ 
		  #print "$Old_word\n";
		  if (!( $MOT[14]==$Old_word)){
		   # print "OK\n";
			print Fout "$MOT[0] J10_2_OUT\n";
		  }
		   $Old_word = $MOT[14];
		}
		if($Label == 3 && $Sublabel == 2 ){ 
			print Fout "$LIGNE\n";
		}
		
	}
	close Fin;
	close Fout;
	# A activer en cas de messages doublon 
	if ($SuppDoublon == 1) {
	  # Suppresion des doublons
	  open Fin1, "<$fichierOutput" or die "impossible d'ouvrir le fichier de sortie $fichierOutput \n";
	  open Fout, ">temp.txt" or die "impossible d'ouvrir le fichier de sortie temp.txt \n";
	  while(<Fin1>){
	    my $Line = $_;
	    chomp $Line;
	    #print "$Line\n";
	    $Line =~ /^(\d\d):(\d\d):(\d\d)\.(\d\d\d)\s(.*)/;
	    my $Heure = $1;
	    my $Minute = $2;
	    my $Seconde = $3;
	    my $Millisec = $4;
	    my $Msg_ID = $5;
	    my $Doublon_ind = 0;
	    open Fin2, "<$fichierOutput" or die "impossible d'ouvrir le fichier de sortie $fichierOutput \n";
	    while(<Fin2>){
	      my $Line2 = $_;
	      chomp $Line2;
	      #print "$Line2\n";
	      $Line2 =~ /^(\d\d):(\d\d):(\d\d)\.(\d\d\d)\s(.*)/;
	      my $Heure2 = $1;
	      my $Minute2 = $2;
	      my $Seconde2 = $3;
	      my $Millisec2 = $4;
	      my $Msg_ID2 = $5;
	      #print "Heure $Heure, Heure2 $Heure2 $Msg_ID2 $Msg_ID $Millisec2 $Millisec\n";
	      #if ($Heure2 > $Heure && $Minute2 > $Minute && $Second2 > $Second ) break
	      if ($Heure2 == $Heure && $Minute2 == $Minute && $Seconde2 == $Seconde && $Msg_ID2 eq $Msg_ID && $Millisec2 > $Millisec) {
		$Doublon_ind = 1;
	      }
	      else {
		next;
	      }
	    }
	    close Fin2;
	    if ($Doublon_ind == 0) { 
	      print Fout "$Line\n";
	    }
	  }
	  close Fin1;
	  close Fout;
	  system("mv temp.txt $fichierOutput");
	}
	print "That all folk !\n";
      }
exit 0;
