## Script Permettant de recuperer les noms et ID des lignes des du reseaux ferre
## d'ile de france disponible sur data.gouv;
## sous le nom de "gares-du-reseau-ferre-dile-de-france.csv" a l'adresse suivante :
## https://www.data.gouv.fr/fr/datasets/gares-du-reseau-ferre-d-ile-de-france-idf/
## Les donnees sont extraite et trie par lignes puis sont formate pour subir une
## transformation au format JSON;

## Note 1: une annexe au nom de _extraction_transilien.awk est necessaire au bon
##			fonctionnement de ce script
##			Il est a mettre dans le meme repertoire que ce script ainsi que
##			du .csv traite par ce script;
##			Il contient peut de ligne que je reporte ici au cas ou il ne serait
##			plus disponible :
#				_extraction_transilien.awk :
					# $NF ~ ez {
					# 	print $0
					# }

## Note 2: Les Noms des Stations sont laisse avec la ponctuation donne dans le
##			fichier initiale;


	############################################################
	######				 INITIALISATION					########
	############################################################


if [ -d "./Lignes_transilien" ];then
	rm -rf Lignes_transilien;
   fi

if [ -d "./TMP" ];then
	rm -rf Lignes_transilien;
   fi

## Creation d'un dossier receptionnant les fichiers finaux
mkdir Lignes_transilien;
mkdir TMP;

## Extrait les colonnes utiles Noms-ID-Noms de lignes
cat gares-du-reseau-ferre-dile-de-france.csv | awk -F\; '{ print $1, ";" $3, ";" $9 }' > TMP/fichier_tmp.csv;


	############################################################
	######			EXTRACTION DES DONNEES				########
	############################################################

## Variable des lignes RER et Transilien
for letter in A B C D E H J K L N P R U
do

		## Catch les lignes entre C et U et les insere dans une fichier.csv pour chacune
			## A NOTER le fichier _extraction_transilien.awk afin d'utiliser une regex dans l'usage de awk
			## //   // defini et "affiche les lignes contenant le contenu de la variable
	awk -v ez=$letter -f _extraction_transilien.awk TMP/fichier_tmp.csv > TMP/tmp_line$letter.csv;

		## Trie les stations dans l'ordre alphabetique et les redirige vers un nouveau fichier
	sort -k 1 TMP/tmp_line$letter.csv > TMP/tmp_1_line$letter.csv;

		## Supprime la derniere colone
	awk '{$NF=""; print $0}' TMP/tmp_1_line$letter.csv > TMP/tmp_2_line$letter.csv;

		## Extrait les ID des stations
	awk -F\; '{print $NF}' TMP/tmp_2_line$letter.csv > TMP/tmp_ID_line$letter.csv;

		## Supprime les espaces et tabulation en debut et fin de ligne
	sed 's/^[ \t]*//;s/[ \t]*$//' TMP/tmp_ID_line$letter.csv > TMP/tmp_ID_1_line$letter.csv;

		## Extrait les Noms des stations
	awk -F\; '{$NF=""; print $0}' TMP/tmp_2_line$letter.csv > TMP/tmp_NAME_line$letter.csv;

		## Supprime les espaces et tabulation en debut et fin de ligne
	sed 's/^[ \t]*//;s/[ \t]*$//' TMP/tmp_NAME_line$letter.csv > TMP/tmp_NAME_1_line$letter.csv

		## Join les colones des deux fichiers
	paste --delimiter=";" TMP/tmp_ID_1_line$letter.csv TMP/tmp_NAME_1_line$letter.csv > TMP/tmp_4_line$letter.csv;

		## Insere le nom des colonnes -> sed -i '1i_name' 1i permet de cibler la
		## premiere ligne du fichier donne en parametre apres la commande SED
	sed -i '1iid;name' TMP/tmp_4_line$letter.csv;

	############################################################
	######			CSV->JSON + Minification			########
	############################################################

		## Convertit fichier CSV en json
	csvtojson --delimiter=";" TMP/tmp_4_line$letter.csv > TMP/tmp_json_line$letter.json;

		## Supprime tous les retours a la ligne afin de minifier la liste.
	cat TMP/tmp_json_line$letter.json | tr "\n" " " > TMP/tmp_json_1_line$letter.json;

		## Supprime l'espace apres la virgule, entre deux cellules.
	cat TMP/tmp_json_1_line$letter.json | awk '{ gsub(", ", ",", $0); print $0 }' > Lignes_transilien/TR_$letter.json;

done

	############################################################
	######			ORGANISATION ET RENOMAGE			########
	############################################################

	## Creation des dossiers des lignes
	mkdir Lignes_transilien/TR;
	mkdir Lignes_transilien/R;

	## Deplace et renome les lignes de RER
	mv Lignes_transilien/TR_A.json Lignes_transilien/R/R_A.json;
	mv Lignes_transilien/TR_B.json Lignes_transilien/R/R_B.json;
	mv Lignes_transilien/TR_C.json Lignes_transilien/R/R_C.json;
	mv Lignes_transilien/TR_D.json Lignes_transilien/R/R_D.json;
	mv Lignes_transilien/TR_E.json Lignes_transilien/R/R_E.json;

	## Deplace les lignes de transilien
	mv Lignes_transilien/*.json Lignes_transilien/TR;

## Suppression des Fichiers Temporaire
rm -rf TMP;
rm -rf *~;
