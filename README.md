Este script genera un PDF con el listado de partes y sus referencias de los coches disponibles en [https://japancars.ru](https://japancars.ru)

## Como instalar
Se necesita bash, pup, pandoc, curl, image-magick, pdftk y bookletimposer. Con ellos instalados, sólo se necesitará el script `gen-epc.sh`.

## Como usar
Primero necesitamos la URL de japancars.ru que contiene las características del coche deseado. Podeis llegar a ella a partir del [catalogo](https://japancars.ru/catalogs) y ahi introducir la marca y caracteristicas de tu coche. Una vez se pulsa continuar, copiar la URL a donde te eres redireccionado.

Ejecutar el script con el primer parametro con la URL entre comillas anterior. Ejemplo:

    $ ./gen-epc.sh "https://japancars.ru/index.php?route=catalog/honda&hmodtyp=9180,9182,9183,9184,9185,9186&cmodnamepc=CIVIC%20CRX&xcardr=2&dmodyr=1992&carea=KG&ctrsmtyp=5MT&xgrade=ESI")

Una vez terminado tendremos dos PDFs. Uno para ser imprimido en DIN A4, y otro para hacerse un cuaderno de medio folio con el.
