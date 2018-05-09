#!/usr/bin/perl

# Affaire : SAMPT
# T�che : mesure du temps de travers�e
# Auteur : S. Mouchot
# Mis � jour : le 23/05/2006
# Description :
# le script extrait du fichier .xhd d'entree dans un fichier texte $RESULT_FILE
# l'heure le tag du champ la valeur du champ le SysTN et pour
# exemple :
# 00:24:21.702 TIME_FUNC_0000 XHD107 TN 0377
# 00:24:21.703 IFF_0001 XHD101 TN 0407
# 00:24:21.704 ID_0000 XHD106 TN 0471
# La valeur de l'IFF est affich�e en octal
# la valeur du sysTN est affich�e en d�cimal

use Getopt::Std;

getopts("hf:");
use lib qw(c:/perlprog/lib);
use Conversion;


if ($opt_h) { 
  print "format_xhd.pl : formate les fichiers xhd au format suivant :\n";
  print " 00:00:00.000 XXXXXXXX YYYYYYYY ZZZZ ZZZZ ZZZZ\n";
  exit(0);
}
if( ! $opt_h && $opt_f) {
	my $fichierInput = "$opt_f";
	my $fichierOutput = "temp.xhd";
	open Fin, "<$fichierInput" or die "impossible d'ouvrir le fichier d'entree $fichierInput \n";
	open Fout, ">$fichierOutput" or die "impossible d'ouvrir le fichier de sortie $fichierOutput \n";
	print "formate $fichierInput to $fichierOutput, please wait...\n";
	while(<Fin>){
		chomp;
		my $LIGNE = $_;
		if($LIGNE !~ /^--/){
		  $LIGNE =~ s/^(\d\d:\d\d:\d\d\.\d\d\d)(.*)/$2/;
		  $TIME = $1;
		  $LIGNE =~ s/\s(\S*)\s/$1/g;
		  #print "$LIGNE\n";
		  $LIGNE =~ s/(\S\S\S\S\S\S\S\S)(\S\S)(\S\S\S\S\S\S)(\S*)/$4/;
		  my $LENGTH = $1;
		  my $MSG_ID = "02$3";
		  $LIGNE =~ s/(\S\S\S\S)/ $1/g;
		  print Fout "$TIME $LENGTH $MSG_ID $LIGNE\n";
		}
		else {
		  print fout "$LIGNE\n";
		}
	      }
      }
system("mv $fichierOutput $fichierInput");
exit 0;
