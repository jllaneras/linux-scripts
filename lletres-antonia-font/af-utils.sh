#!/bin/bash

URL_VIASONA="http://www.viasona.cat/grup/antonia-font/totes-les-lletres"

function corregir_text() {
	# Copiar stdin a un fitxer temporal.
	fitxer_tmp=/tmp/$RANDOM.tmp
	cat /dev/stdin > $fitxer_tmp

	# Eliminar espais a començament de línia.
	sed -i -r "s/^( +)//g" $fitxer_tmp
	# Eliminar <br/>.
	sed -i "s/<br\/>//g" $fitxer_tmp
	# Reemplaçar &#39; per '.
	sed -i "s/&#39;/'/g" $fitxer_tmp
	# Reemplaçar ´ per '.
	sed -i "s/´/'/g" $fitxer_tmp
	# Eliminar símbol no imprimible.
	sed -i "s///g" $fitxer_tmp
	# Reemplaçar caràcter estrany (no és un espai) per un espai.
	sed -i "s/ / /g" $fitxer_tmp
	# Eliminar cometes simples repetides.
	sed -i "s/''/ \"/g" $fitxer_tmp
	# Eliminar espais repetits
	sed -i -r "s/( +)/ /g" $fitxer_tmp
	# Assegurar que hi ha un espai darrera cada punt (en fer el recompte de
	# paraules seran eliminats).
	# Excepcions: quan estan entre números (30.000), quan formen part de 
	# sigles (S.O.S.) i quan són punts suspensius (...).
	sed -i -r "s/([a-z]+)\.([A-Z]+)/\1\. \2/g" $fitxer_tmp
	# Assegurar que hi ha un espai darrera els signes d'interrogació
	# (ja que posteriorment seran eliminats).
	sed -i "s/\?/\? /g" $fitxer_tmp

	# Imprimir a stdout.
	cat $fitxer_tmp
	rm $fitxer_tmp
}

function baixar_lletres() {
	# Obtenir els enllaços a les lletres de les cançons.
	wget -O- $URL_VIASONA | hxnormalize -x | hxselect -i "div.titol > a" | \
	sed -r "s/href/\nhref/g" | grep href | \
	sed -r "s/href=\"([^\"]+)([^$]+)/\1/g" > resultats/urls-lletres-af.txt

	# Baixar les pàgines HTML de totes les cançons.
	mkdir resultats/pagines-html-lletres
	wget -P resultats/pagines-html-lletres -i resultats/urls-lletres-af.txt

	# Extreure les lletres de les pàgines HTML.
	mkdir resultats/lletres
	cd resultats/pagines-html-lletres
	for f in `ls`
	do
		hxnormalize -x $f | \
		hxselect -c -i "p.contingut_lletra" | corregir_text > ../lletres/$f
	done

	cd ../..
}

function processar_text() {
	# Copiar stdin a un fitxer temporal.
	fitxer_tmp=/tmp/$RANDOM.tmp
	cat /dev/stdin > $fitxer_tmp

	# Eliminar caràcters especials.
	sed -i "s/[,.;:\¿\?\!\(\)\"]//g" $fitxer_tmp
	# Eliminar guions a començament de línia.
	sed -i "s/^\-//g" $fitxer_tmp
	# Convertir-ho tot a minúscules.
	sed -i -e "s/./\L&/g" $fitxer_tmp
	# Eliminar partícules apostrofades al començament de paraules.
	sed -i -r "s/(d')|(l')|(m')|(n')|(s')|(t')//g" $fitxer_tmp
	# Reemplaçar espais per salts de línia (per aplicar uniq posteriorment).
	sed -i "s/ /\n/g" $fitxer_tmp
	# Eliminar línies en blanc.
	sed -i "/^$/d" $fitxer_tmp
	
	# Imprimir a stdout.
	cat $fitxer_tmp
	rm $fitxer_tmp
}
