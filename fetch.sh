#!/bin/bash

declare -i pages
url="https://www.ocr.gov.np/CRO/faces/pages/admin/NsicCodeHelp.jsp"

echo "* Initializing"
curl -c ocr-jar.txt -s "${url}" > /dev/null

echo "* First page"
curl -b ocr-jar.txt -s "${url}" > dump.html

pages=$(cat dump.html | tr -d '\n' | sed 's#.*<td>1/\([0-9]\+\).*#\1#g')
hidden_vals=$(cat dump.html | grep 'input type="hidden"' | sed 's/.*name\s*=\s*"\([^"]\+\)".*value="\([^"]\+\)".*/\1=\2\&/g' | tr -d '\n')
ajaxSingle=$(cat dump.html | grep 'ajaxSingle' | sed "s/.*ajaxSingle':'j_id_\([^']\+\).*/j_id_\1/g" )

ajaxId=$(echo "$ajaxSingle" | cut -d ':' -f 1 | sed 's/_1$/_0/' )
ajaxSingleEncoded=$(echo $ajaxSingle | sed 's/:/%3A/g')

echo "* TOTAL PAGES : ${pages}"

for i in $(seq 1 $pages); do
echo "* Fetching page $i"
curl "${url}" \
  -X POST \
  -s \
  -H 'Pragma: no-cache' -H 'Origin: https://www.ocr.gov.np' -H 'Accept-Encoding: gzip, deflate, br' \
  -H 'Accept-Language: en-US,en;q=0.8,hi;q=0.6,ms;q=0.4,ne;q=0.2' \
  -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/50.0.2661.49 Safari/537.36' \
  -H 'Content-Type: application/x-www-form-urlencoded; charset=UTF-8' -H 'Accept: */*' \
  -H 'Cache-Control: no-cache' -H 'Referer: https://www.ocr.gov.np/CRO/faces/pages/admin/NsicCodeHelp.jsp' \
  -H 'Connection: keep-alive' -H 'Save-Data: on' \
  -b ocr-jar.txt \
  --data "AJAXREQUEST=${ajaxId}&${hidden_vals}&ajaxSingle=${ajaxSingleEncoded}&${ajaxSingleEncoded}=next" --compressed >> dump.html
done

# Update from the fetched HTML
bash update.sh

echo "* Written to nsic-codes.json"
echo "* Done"

