#!/bin/bash
DIR_LIVRAISON=/h7_usr/sil2_usr/ganivq/Livraison
ESPACE_REFERENCE=/h7_usr/sil2_usr/ganivq/Espace_de_reference/EXECUTABLES
DIR_FICHIER_VERSION=/h7_usr/sil2_usr/ganivq/Configuration
BIN_COMMANDER=commander_main
BIN_COMMANDER_LINUX=commander_main_linux
BIN_CORE_MANAGER=appli_Core_Manager
BIN_CORE_SUPERVISOR=Supervision
GAN_VERSION_TXT=$DIR_FICHIER_VERSION/../GAN_Version.txt
CPT_ERROR=0
CPT_INSTAL=0
cd $DIR_FICHIER_VERSION
echo $BIN_COMMANDER > _BIN_list
echo $BIN_COMMANDER_LINUX >> _BIN_list
echo $BIN_CORE_MANAGER >> _BIN_list
echo $BIN_CORE_SUPERVISOR >> _BIN_list

# on se place dans l'espace de livraison des binaires
cd $DIR_LIVRAISON

#on nettoie les rep temportaires concernant les versions dans appli à à deployer
rm -rf $DIR_FICHIER_VERSION/PRET_A_COPIER
mkdir -p $DIR_FICHIER_VERSION/PRET_A_COPIER

# on boucle sur la lecture du fichier GAN_Version.csv dans lequel se trouve les versions des appli demandé par l'opérateur pour etre deployer sur les machines
for i in $(cat $DIR_FICHIER_VERSION/GAN_Version.csv  | awk '{print $1}' ) 
do 
	NOM_APPLI=`echo $i | cut -d\; -f1`
	NOM_VERSION=`echo $i | cut -d\; -f2`

# on trouve la version GAN
	if test "$NOM_APPLI" = "GAN"
	then
		GAN_Version_NAME=$NOM_APPLI
		GAN_Version_No=$NOM_VERSION
		echo "$GAN_Version_NAME"  "$GAN_Version_No" > $GAN_VERSION_TXT
		continue
	fi
	
# puis pour chaque autre appli on stock dans les variables le nom et la verison de l'appliation
	echo
	echo "NOM APPLI = $NOM_APPLI "
	echo "NOM VERSION = $NOM_VERSION"
	cd $DIR_LIVRAISON/$NOM_APPLI

# on cherche le No version dans la chaine de car du nom du rep de livraison des binaires
	VERSION_A_TROUVER=`ls -d *$NOM_VERSION* `
	if [ $? -ne 0 ]; then
#aucune version n'est trouvée dans l'arborescance de l'application correspondant à celle demandée par l'opérateur	
		echo "===================================================================="
		echo "Version $VERSION_A_CHERCHER de $NOM_APPLI non trouvee"
		echo "===================================================================="
		ERROR=1
		CPT_ERROR=`expr $CPT_ERROR + 1`
		echo "$NOM_APPLI"  "ERROR - $NOM_VERSION " >> $GAN_VERSION_TXT
	else
# on trouve une correspondance entre le No de version demandé par l'opérateur et celle trouvée dans l'arborescance de livraison des applications	
		cd $VERSION_A_TROUVER
		mkdir -p $DIR_FICHIER_VERSION/PRET_A_COPIER/$VERSION_A_TROUVER
# une fois trouvé, on recherche le nom du binaire faisant référence à une liste de tous les bianaires des appli à copier dans l'espace de référence
		for b in $(cat $DIR_FICHIER_VERSION/_BIN_list)
		do 		
			BIN_TROUVE=`find . -name $b`			
			if ! test "$BIN_TROUVE" = "" 
			then				
#on a trouvé le binaire correspondant à l'application et on le copie dans un répertoire temporaire "PRET_A_COPIER"	
				echo "BIN_TROUVE = $BIN_TROUVE"	
				cp $BIN_TROUVE $DIR_FICHIER_VERSION/PRET_A_COPIER/$VERSION_A_TROUVER
				chmod +x $DIR_FICHIER_VERSION/PRET_A_COPIER/$VERSION_A_TROUVER
			fi
		done
		CPT_INSTAL=`expr $CPT_INSTAL + 1`
		echo "$NOM_APPLI"  "$NOM_VERSION " >> $GAN_VERSION_TXT
	fi
		echo $VERSION_A_TROUVER
done

#echo "TOTAL APPLI TROUVEE = $CPT_INSTAL"
#echo "Nb Erreurs trouvees = $CPT_ERROR"
cd $DIR_FICHIER_VERSION
rm -f _BIN_list

echo "GAN_Version.txt = $GAN_VERSION_TXT"
mv $GAN_VERSION_TXT $ESPACE_REFERENCE/..

# si il n'y a eu aucune erreur : alors on deploie les binaires du repertoire temporaire "PRET_A_COPIER" vers l'espace de reférence
if test $CPT_ERROR -eq 0
then
	echo "==================================================================================================="
	echo "RECOPIE des APPLICATIONS GAN dans l espace de reference"
	echo "==================================================================================================="
	for i in COMMANDER CORE_MANAGER CORE_SUPERVISOR
	do
		echo
		echo
		echo "cp $DIR_FICHIER_VERSION/PRET_A_COPIER/$i*/* $ESPACE_REFERENCE/$i/"
		ls -l $DIR_FICHIER_VERSION/PRET_A_COPIER/$i*/* 
		cp $DIR_FICHIER_VERSION/PRET_A_COPIER/$i*/* $ESPACE_REFERENCE/$i/
 
		if [ $? -ne 0 ]; then
			echo "===================================================================="
			echo "Impossible de copier les binaires de $i dans l'espace de reference"
			echo "===================================================================="
			ERROR=1
			CPT_ERROR=`expr $CPT_ERROR + 1`
		fi
	done
fi
