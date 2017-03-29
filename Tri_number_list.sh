## Cat affiche le contenu
## Le premier Sed supprime le premier "
## Sort -n trie numeriquement
## Le denier Sed remet le " en debut de ligne

cat liste_a_trier.ezlife | sed 's/^\"*//g' | sort -n | sed -e 's/^./\"&/g' > Liste_trier.ezlife
