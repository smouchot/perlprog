#!/usr/bin/perl -w

# Affaire : SAMPT
# T�che : automatisation des tests
# Auteur : S. Mouchot
# Mis � jour : le 02/05/2007
# Description :

use Getopt::Std;

my @MOT;
my $Delta_Error = "00:00:02.000";

getopts("hf:");



if ($opt_h) { 
  print "remove_xdh_technique.pl -f nom_fichier : tri les messages Msd_ID  > 100 ou = 92 ";
  exit(0);
}
if( ! $opt_h && $opt_f) {
  $fichierInput = "$opt_f";
$fichierOutputBak = "opt_f.bak";
  $fichierOutput = "$opt_f.tmp";

  open Fin, "<$fichierInput" or die "impossible d'ouvrir le fichier d'entree $fichierInput \n";
  open Fout, ">$fichierOutput" or die "impossible d'ouvrir le fichier de sortie $fichierOutput \n";
 open Fout2, ">$fichierOutputBak" or die "impossible d'ouvrir le fichier de sortie $fichierOutputBak \n";	
  print "remove tdh from $fichierInput , please wait...\n";
   while(<Fin>){
    chomp;
	
    	my $LIGNE = $_;
	print Fout2 "$LIGNE";
    (@MOT) = (split " ",$LIGNE);
     next if (! ($MOT[2] =~ /^01/));
    #print "$MOT[2]\n";
    my $Length_xdh = scalar @MOT;
    my $Msg_ID = hex (substr($MOT[2],-2,2));
    # Ne traite pas les messages techniques
    if($Msg_ID > 100 || $Msg_ID == 92){
      print Fout "$LIGNE\n";
    }
  }
  close Fin;
  close Fout;
	close Fout2;
	system("mv $fichierOutput $fichierInput");
  exit 0;
}
