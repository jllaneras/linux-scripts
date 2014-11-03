#!/bin/bash

source af-utils.sh

if [ ! -d "resultats" ]; then
	mkdir resultats
fi

baixar_lletres

cd resultats/lletres/

mkdir ../paraules
# "ls --ignore=*.?" llista tots els noms de fitxers que no acaben amb
# punt seguit d'un número (cançons repetides en diferents discs: alegria.1, alegria.2, ...).
# A continuació es posen totes les lletres dins un únic fitxer.
ls --ignore=*.? | xargs cat | processar_text > ../paraules/lletres_processades.txt
# Recompte.
printf "Número de vedades que la paraula apareix a les lletres d'Antònia Font:\n\n" > ../paraules/frequencies.txt
cat ../paraules/lletres_processades.txt | sort | uniq -c | sort -nr >> ../paraules/frequencies.txt

mkdir ../cançons_per_paraula
# S'obtenen les paraules úniques de cada cançó i es posen dins un únic fitxer.
for f in `ls --ignore=*.?`
do
	cat $f | processar_text | sort | uniq >> ../cançons_per_paraula/lletres_processades.txt
done
# Recompte.
printf "Número de cançons d'Antònia Font on apareix la paraula:\n\n" > ../cançons_per_paraula/frequencies.txt
cat ../cançons_per_paraula/lletres_processades.txt | sort | uniq -c | sort -nr >> ../cançons_per_paraula/frequencies.txt
