package Carre;

my $MAX;

sub new {
	my $indice = shift;
	$MAX = shift;
	my $r_carre = {
			"indice" => $indice,
			"MAX" => $MAX,
			"nbre_inconnue" => 0,
			"cellule" => [],
			"ligne" => undef,
			"colonne" => undef,
			"carre" => undef
		};
	bless $r_carre;
	return $r_carre;
}

sub checkHypothesis {
	my $r_carre = shift;
	my $valeur = shift;
	my $test = 1;
	foreach $r_cellule (@{$r_carre->{cellule}}){
		if ($r_cellule->{valeur} == $valeur){
			$test = 0;
			last;
		}
	}
	return $test;
}

sub contientValeur {
	my $r_carre = shift;
	my $valeur = shift;
	my $test = 0;
	my $r_array = $r_carre->{cellule};
	my $indice_l = $r_carre->{indice};
	#print "Recherche carre n $indice_l value $valeur\n";
	foreach my $r_cellule (@$r_array){
		my $valeur_contenue = $r_cellule->{valeur};
		my $indice =$r_cellule->{indice};
		#print "Cellule $indice Value $valeur_contenue\n";
		if ($valeur_contenue == $valeur){
			$test = 1;
			last;
		}
	}
	return $test;
}


sub addCell {
	my $r_carre = shift;
	my $r_cellule = shift;
	my $r_array = $r_carre->{cellule};
	push (@$r_array, $r_cellule);
	if ($r_cellule->{value} == 0) {
		$r_carre->{"nbre_inconnue"} += 1;
	}
	return $r_carre->{nbre_inconnue};
}

sub contientCellule {
	my $r_carre = shift;
	my $r_cellule = shift;
	my $MIN = int(sqrt($MAX));
	#print "Min : $MIN\n";
	my $indice_carre = $r_carre->{indice};
	my $indice_cell = $r_cellule->{indice};
	my $indice_ligne = int($indice_cell / $MAX);
	my $indice_colonne = $indice_cell % $MAX;
	#print "carre $indice_carre; cell $indice_cell\n";
	my $a = int($indice_colonne / $MIN)+($MIN * int(($indice_ligne / $MIN)));
	#print "indice carre calcul� = $a\n";
	if( $a == $indice_carre ) {
		#print " ligne : $indice_ligne\n";
		#print " colonne : $indice_colonne\n";
		print " cell $indice_cell dans carre ind = $a\n";
		return 1;
	}
	else {
		return 0;
	}
}

1
	
	
