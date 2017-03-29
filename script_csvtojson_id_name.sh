mkdir Test_json;

## Creer un fichier texte avec tous les noms de ligne sur une string
#ls -l | grep RATP_GTFS_ | awk -F\_ '{ print $3_,$4 }' | tr " " "_" | tr "\n" " " > list_ligne.txt;

for nb in $(ls -l | grep RATP_GTFS_ | awk -F\_ '{ print $3_,$4 }' | tr " " "_" | tr "\n" " "); #Liste les noms de lignes
do
    
## Permet d'extraire les colones 1 et 3 de chaque fichier cible avec CAT et insere ces elements dans un fichier ligneX.txt
    cat RATP_GTFS_$nb/stops.txt | awk -F, '{ print $1, $3 }' | grep \" > Test_json/m_ligne_$nb.txt;

## Tri la deuxieme colonne et supprime les doublons.
    sort -k 2 Test_json/m_ligne_$nb.txt | uniq -f 1 > Test_json/tmp_$nb.txt

## Insere les noms des colonnes -> sed -i '1itexte_a_insere' 1i permet de cible la premiere ligne du fichier donne en parametre apres la commande SED
    sed -i '1iid name' Test_json/tmp_$nb.txt;

## Convertit fichier CSV en json
     csvtojson --delimiter=" " Test_json/tmp_$nb.txt > Test_json/t_ligne_$nb.json;

## Supprime tous les retours a la ligne afin de minifier la liste.
     cat Test_json/t_ligne_$nb.json | tr "\n" " " > Test_json/line_ligne_$nb.json;

## Supprime l'espace apres la virgule, entre deux cellules.
     cat Test_json/line_ligne_$nb.json | awk '{ gsub(", ", ",", $0); print $0 }' > Test_json/$nb.json;

done

## Suppression des fichiers temporaires
rm -rf Test_json/t_ligne* Test_json/line_* Test_json/m_ligne* Test_json/tmp_*;

## Mise en place des dossiers  de la base de donnee.
mkdir Test_json/M
for name in $(ls -l Test_json/METRO*.json | awk -F\_ '{print $3 }');
do
	mv Test_json/METRO_$name Test_json/M/M_$name;
done

mkdir Test_json/B
for name in $(ls -l Test_json/BUS*.json | awk -F\_ '{print $3 }');
do
	mv Test_json/BUS_$name Test_json/B/B_$name;
done

mkdir Test_json/R
for name in $(ls -l Test_json/RER*.json | awk -F\_ '{print $3 }');
do
	mv Test_json/RER_$name Test_json/R/R_$name;
done

mkdir Test_json/T
for name in $(ls -l Test_json/TRAM*.json | awk -F\_ '{print $3 }');
do
	mv Test_json/TRAM_$name Test_json/T/T_$name;
done
