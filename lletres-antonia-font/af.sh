#!/bin/bash

# Pàgina amb enllaços a totes les cançons d'Antònia Font
URL_VIASONA="http://www.viasona.cat/grup/antonia-font/totes-les-lletres"

# Obtenir els enllaços a les lletres de les cançons
wget -O- $URL_VIASONA | hxnormalize -x | hxselect -i "div.titol > a" | \
sed -r "s/href/\nhref/g" | grep href | \
sed -r "s/href=\"([^\"]+)([^$]+)/\1/g" > urls-lletres-af.txt

mkdir resultat
mkdir pagines-cançons
cd pagines-cançons

# Davallar les pàgines HTML de totes les cançons
cat ../urls-lletres-af.txt | wget -O- -i-

# Extreure les lletres de les pàgines HTML i posar-les en un fitxer
# "ls --ignore *.?" llista tots els noms de fitxers que no acaben amb
# punt seguit d'un número (cançons repetides: alegria.1, alegria.2, ...).
ls --ignore "*.?" | xargs cat | hxnormalize -x | \
hxselect -c -i "p.contingut_lletra" > ../resultat/lletres.txt

cd ../resultat
cp lletres.txt lletres_tmp.txt

# Eliminar espais a començament de línia
sed -i -r "s/^( +)//g" lletres_tmp.txt
# Eliminar <br/>
sed -i "s/<br\/>//g" lletres_tmp.txt
# Reemplaçar &#39; per '
sed -i "s/&#39;/'/g" lletres_tmp.txt
# Assegurar que hi ha espais darrera els punts (abans d'eliminar-los)
# Excepcions: quan estan entre números (30.000), quan formen part de 
# sigles (S.O.S.) i quan són punts suspensius (...).
sed -i -r "s/([a-z]+)\.([A-Z]+)/\1\. \2/g" lletres_tmp.txt
# Assegurar que hi ha un espai darrera els signes d'interrogació (abans d'eliminar-los)
sed -i "s/\?/\? /g" lletres_tmp.txt
# Eliminar caràcters especials
sed -i "s/[,.;:\¿\?\!\(\)\"]//g" lletres_tmp.txt
# Eliminar guió a començament de línia
sed -i "s/^\-//g" lletres_tmp.txt
# Reemplaçar ´ per '
sed -i "s/´/'/g" lletres_tmp.txt
# Eliminar símbol no imprimible
sed -i "s///g" lletres_tmp.txt
# Reemplaçar caràcter estrany (no és un espai) per un espai
sed -i "s/ / /g" lletres_tmp.txt
# Eliminar cometes simples repetides
sed -i "s/''/ /g" lletres_tmp.txt
# Eliminar múltiples espais
sed -i -r "s/( +)/ /g" lletres_tmp.txt
# Convertir-ho tot a minúscules
dd if=lletres_tmp.txt of=lletres_processades.txt conv=lcase
# Eliminar partícules apostrofades al començament de paraules
sed -i -r "s/(d')|(l')|(m')|(n')|(s')|(t')//g" lletres_processades.txt

rm lletres_tmp.txt

# Obtenir el llistat de freqüències de paraules per ordre decreixent
cat lletres_processades.txt | tr ' ' '\n' | sort | uniq -c | sort -nr > frequencies.txt
