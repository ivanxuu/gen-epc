#!/bin/bash
if [[ $# -eq 0 ]]
then
  echo 'Genera catalogo de partes de un coche a partir de la URL de japancars.ru'
  echo '  Ej: ./gen-epc.sh "https://japancars.ru/index.php?route=catalog/honda&hmodtyp=9180,9182,9183,9184,9185,9186&cmodnamepc=CIVIC%20CRX&xcardr=2&dmodyr=1992&carea=KG&ctrsmtyp=5MT&xgrade=ESI"'
else
  rm *.pdf
  mainpage=$(curl --cookie "language=en; currency=EUR" -s "$1")
  #Portada
  echo -e "Catálogo de piezas========================\n\n\n\n\n\n" > header.md
  echo $mainpage | pup "#tab-model-info" | pandoc -f html-native_divs-native_spans -t markdown -o header.md
  pandoc header.md -V pagestyle=empty -V geometry:"top=4cm, bottom=1cm, left=3cm, right=3cm" -o 0000-0000-0.pdf
  sectioncounter_raw=0
  echo $mainpage | pup "#epc li a attr{href}" | sed 's/&amp;/\&/g' | sed 's/\s/%20/g' | while read sectionlink
  do
    ((sectioncounter_raw++))
    sectioncounter=`printf '%04d' $sectioncounter_raw`
    #echo "Descargando seccion $sectioncounter de $sectionlink"
    section=$(curl --cookie "language=en; currency=EUR" -s $sectionlink )
    pagecounter=0000
    echo $section > debug
    echo $section | pup "#epc table.list tr td:nth-child(2) a attr{href}" | sed 's/\s/%20/g' | sed 's/&amp;/\&/g' | while read pagelink
    do
      ((pagecounter_raw++))
      pagecounter=`printf '%04d' $pagecounter_raw`
      #echo "Descargando pagina $pagecounter de $pagelink"
      page=$(curl --cookie "language=en; currency=EUR" -s "$pagelink")
      #section name
      read name < <(echo $page | pup "#content .breadcrumb a:last-child text{}")
      #echo -e "## $name\n" > page.md
      #image
      #read imagelink < <(echo $page | pup "#img attr{src}")
      curl -s "https://japancars.ru$(echo $page | pup "#img attr{src}")" -o $pagecounter.gif
      #echo '!['$name']('"https://japancars.ru$imagelink"')' >>page.md
      echo '!['$name']('"$pagecounter.gif"')' >page.md
      mogrify -rotate -90 $pagecounter.gif
      #join page and image in landscape
      #pandoc page.md -V pagestyle=empty -V geometry:landscape -V geometry:"top=2cm, bottom=1cm, left=1cm, right=1cm" -o $sectioncounter-$pagecounter-0-raw.pdf
      pandoc page.md -V pagestyle=empty -V geometry:"top=0.5cm, bottom=1cm, left=0.5cm, right=0.5cm" -o $sectioncounter-$pagecounter-0.pdf
      #pdftk $sectioncounter-$pagecounter-0-raw.pdf rotate 1-endwest output $sectioncounter-$pagecounter-0.pdf
      #rm $sectioncounter-$pagecounter-0-raw.pdf
      # Generar listado de piezas en modo retrato

      echo -e "---\nfontsize: 8pt\n---\n" >parts.md
      echo $page | pup "#epc .list" | pandoc -f html-native_divs-native_spans -o parts2.md
      cat parts.md parts2.md | pandoc -V pagestyle=empty -V geometry:"top=2cm, bottom=0.5cm, left=0.5cm, right=0.5cm" -o $sectioncounter-$pagecounter-1.pdf
      #pandoc parts.md -V pagestyle=empty -V geometry:"top=2cm, bottom=0.5cm, left=0.5cm, right=0.5cm" -f html-native_divs-native_spans -o $sectioncounter-$pagecounter-1.pdf
      # Añadir pagina si es numero par para no descuadrar que la imagen siempre aparezca en pagina impar
      read numpages < <(pdftk $sectioncounter-$pagecounter-1.pdf dump_data | grep NumberOfPages  | awk '{print $2}')
      if (( $numpages % 2 == 0 ))
      then
        echo "Pagina de piezas con numero par. Añadiendo pag extra"
        pdftk $sectioncounter-$pagecounter-1.pdf .blank.pdf cat output $sectioncounter-$pagecounter-1.temp.pdf
        mv $sectioncounter-$pagecounter-1.temp.pdf $sectioncounter-$pagecounter-1.pdf
      fi
      echo "Descargado $name"
    done
  done
  pdftk *.pdf  cat output honda-epc.pdf
  bookletimposer -o honda-epc.encuadernar.pdf --no-gui --booklet honda-epc.pdf
  rm *.md
fi
