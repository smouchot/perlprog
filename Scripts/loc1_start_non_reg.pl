#!/usr/bin/perl -w

use Getopt::Std;

getopts("hc:v:f:");

if ($opt_h) { 
	print "loc1_start_non_reg [-c] [-h] : liste des versions dlip \n";
#	print "\t liste des versions dlip: \n";
	print "loc1_start_non_reg [-c] [-v n_version ] [-f file_list_file] : lance la nom reg \n";
	print " \n";
}
my @TEST_LIST_START;
my @TEST_LIST_LAUNCHER;
my $REP_BASE = "/data/users/loc1int/DLIP/test/test_tu";
my $REP_COMMON_FILES = "common_files";
my $REP_RESULTAT = "results";
my $REP_CIBLE;
my $REP_FILE_LIST;
my $LIST_FILE_NAME = "test_duration_list.txt";
my $CAT = 2;
my $VERSION_DLIP;
my $NOM_TEST;
my $TIME = 900;
my $VALUE;

if ($opt_h && $opt_c && ! $opt_v) {
  $CAT = $opt_c;
  print "categorie = $CAT \n";
  my $LISTE = `ls $REP_BASE/category$CAT`;
  print "Liste des versions DLIP en test cat�gorie $CAT :\n";
  print "$LISTE";
  print " \n";
}
if( ! $opt_h && $opt_c && $opt_v ) {
  $CAT = $opt_c;
  $VERSION_DLIP = $opt_v;

  # Lecture de la liste des tests
  if ($opt_f) {    
    $LIST_FILE_NAME = $opt_f;
  }
  $REP_FILE_LIST = "$REP_BASE/category$CAT/$REP_COMMON_FILES";
  print "$REP_FILE_LIST\n";
  my %TEST_LIST;
  open Fin, "<$REP_FILE_LIST/$LIST_FILE_NAME" or die "impossible ouvrir $REP_FILE_LIST/$LIST_FILE_NAME\n";
  while(<Fin>){
    chomp $_;
    my $TEST_NAME = $_;
    if ( $TEST_NAME !~ /^--/){
     my ($TEST_NAME, $TEST_DURATION) = (split (":", $TEST_NAME));
      #print "test = $TEST_NAME\n";
     $TEST_LIST{$TEST_NAME}=$TEST_DURATION;
    }
  }
  close Fin;

  # conversion des fichiers .xhd au format unix 
  system("XHD_conv2unix -c $CAT -v $VERSION_DLIP");

  while (my ($NOM_TEST,$TIME) = each (%TEST_LIST)){
    #print "Nom du Test = $NOM_TEST, Duree = $TIME\n";
   if($NOM_TEST =~ /^L11_/ && $TIME ne "x" && $CAT == 2 ){
     print " $NOM_TEST est un test CTIF L11 de cat�gorie 2 \n";
     print " Test � passer manuellement\n\n";
   }
   else {
     $REP_CIBLE = "$REP_BASE/category$CAT/$VERSION_DLIP/$NOM_TEST";
     if (-d "$REP_BASE/category$CAT/$VERSION_DLIP/$NOM_TEST") {
       chdir "$REP_CIBLE" or die "Impossible positionner le rep $REP_CIBLE\n";
       $TOTO = `pwd`;
       chomp $TOTO;
       print "Repertoire de test $TOTO positionn� \n";
       system("loc1_start_test.pl -c $CAT -v $VERSION_DLIP -t $NOM_TEST -x");
     }
     else {
       print "$REP_BASE/category$CAT/$VERSION_DLIP/$NOM_TEST n'est pas un repertoire !\n";
       print "$NOM_TEST non pass� ...\n";
     }
   }
 }
  # creation des fichiers error.txt, global_error.txt, result_summarize.txt
  system("test_result_summurize.pl -c $CAT -v $VERSION_DLIP");
  exit 0;
}

