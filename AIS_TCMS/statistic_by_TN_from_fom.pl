#!/usr/bin/perl -w

# Affaire : SAMPT
# T�che : mesure du temps de travers�e
# Auteur : S. Mouchot
# Mis � jour : le 26/05/2006
# Description :
# extrait de l'entr�e standard les messages J3.X J2.X avec leur TN / Source TN 
# dans des fichiers de type J3_y_TN_zzzzz.fom ou J2_y_STN_zzzzz.fom

use Getopt::Std;

my @MOT;
my $RESULTS_FILE = "fom_arrival_times_and_tns.txt";
my $fichierOutput;

getopts("hf:");

my $Offset_motI=8; # offset du mot I dans le tableau @MOT $MOT[13].$MOT[14] est le 1er boctet

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
	print "Jvalue : $JValue\n";
	return $JValue;
}

sub getBoctetHexaString {
	my $Boctet_number = shift;
	my $Boctet_index = getIndexforBoctet($Boctet_number);
	my $String = $MOT[$Boctet_index];
	print "BoctetHexaString : $String\n";
	return $String;
}

sub getIndexforBoctet {
	my $Boctet_number = shift;
	my $IndexforBoctet = $Offset_motI + $Boctet_number;
	print "index : $IndexforBoctet\n";
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
    print "hexa : $string \n";
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
    print "Octal : $string \n";
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
	print "$Boctet : $Last_bit_position\n";
	my $Mask = (2**($Last_bit_position))-1;
	my $Boctet_value = hex($Boctet) & $Mask;
	print "$Mask : $Boctet_value \n";
	return $Boctet_value;
}

sub toChrono {
	my ($heure, $minute, $seconde, $milliseconde);
	$heure = shift;
	print  "heure : $heure\n";
	($heure, $minute, $seconde) = split(':', $heure);
	print "seconde : $seconde\n";
	($seconde, $milliseconde) = split('\.', $seconde);
	print "heure : $heure, $minute, $seconde, $milliseconde\n";
	$seconde = $seconde + ($milliseconde/1000);
	print "heure : $heure $minute $seconde $milliseconde\n";
	my $chrono = $heure*3600 + $minute*60 + $seconde;
	print "chrono : $chrono\n";
	#<>;
	return $chrono;
	
}

if ($opt_h) { 
  print "extract_TN_date_from_fom.pl -f nom_fichier : extrait";
  exit(0);
}

if( ! $opt_h ) {
	my $fichierInput = "$opt_f";
	my $fichierOutput = "$RESULTS_FILE";
	print "Suppression des fichiers resultats...\n";
	system ("del /F J3-2-TN*.fom ");
	open Fin, "<$fichierInput" or die "impossible d'ouvrir le fichier d'entree $fichierInput \n";
	#open Fout, ">$fichierOutput" or die "impossible d'ouvrir le fichier de sortie $fichierOutput \n";
	#print " Create $fichierOutput from $fichierInput, please wait...\n";
	#for $I (0..15) {
	#	my $valeur = maskOctetLastBit("FFFF", $I);
	#}
	#exit 0;
	my @staticTargetArray;
	foreach my $index (128..328) {
		$staticTargetArray[$index]=0;
	}
	my $firstTarget = 1;
	my $firstChrono = 0;
	my $lastChrono = 0;
	
	while(<Fin>){
		chomp;
		my $LIGNE = $_;
		@MOT = split " ",$LIGNE;
		print "$MOT[8]\n";
		# Recherche du label et du sublabel
		my $Label_bit_offset=2;
		my $Label_bit_number=5;
		my $Label = getJValue($Label_bit_offset, $Label_bit_number);
		my $Sublabel_bit_offset=7;
		my $Sublabel_bit_number=3;
		my $Sublabel = getJValue($Sublabel_bit_offset, $Sublabel_bit_number);
		print "Label : $Label SubLabel : $Sublabel\n";
exit 0;
		if($Label == 3 && ($Sublabel == 0 || $Sublabel == 2 ||$Sublabel == 3 || $Sublabel == 5)){
			if ($firstTarget == 1){
				$firstChrono = toChrono($MOT[0]);
				$firstTarget = 0;
			}
			else {
				$lastChrono = toChrono($MOT[0]);
			}
			my $TN_bit_offset = 19;
			my $TN_bit_number= 19;
			my $String_value = getJValue($TN_bit_offset, $TN_bit_number) ;
			$staticTargetArray[$String_value] += 1;
			$staticTargetArray[328] += 1;	
			#print "$String_value\n";
			$fichierOutput = "J$Label-$Sublabel-TN_$String_value.fom";
			open Fout, ">>$fichierOutput" or open ">$fichierOutput" or die "impossible d'ouvrir le fichier de sortie $fichierOutput \n";
			print Fout "$LIGNE\n";
			close Fout;
		}

	}
	close Fin;
	open Fout, ">statisticTargetFom.cvs" or die "Impossible ouvrir fichier";
	print Fout "D�but du test = $firstChrono\n";
	print Fout "Fin du test =  $lastChrono\n";
	$lastChrono = $lastChrono - $firstChrono;
	print Fout "Dur�e du test = $lastChrono\n";
	my $nbreMsgAttendu = ($lastChrono-420)*50;# 280 correspond au period ou les target ne sont pas refraiichi RRN = 3
	my $temp = $staticTargetArray[328] * 100 / $nbreMsgAttendu;
	print Fout "Taux d'�mission = $temp\n";
	
	foreach my $index (128..328) {
		print Fout "Nbre Target index $index = $staticTargetArray[$index]\n";
	}
	close Fout;
}

print "That's all folk !\n";
exit 0;