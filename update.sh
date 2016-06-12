#!/bin/bash
html=$(cat dump.html | tr -d '\n')
rows=$(echo "$html" | grep label | sed 's#<label>\([^<]\+\)</label>#\nXCELLX\1\n#g' | grep "^XCELLX" | sed 's/^XCELLX//g' )
if [ ! -d "/var/tmp/nepalese-github" ]; then
  mkdir /var/tmp/nepalese-github
fi

echo "$rows" > /var/tmp/nepalese-github/ocr.tmp
python <<END
import json
f=open("/var/tmp/nepalese-github/ocr.tmp")
ofile=open("nsic-codes.json", "w")
count=0
node={}
rows={}

cols = ["code", "en", "ne"]
for line in f.readlines():
  colno=count%3
  colname = cols[colno]
  if colno == 0:
    node = {}
    code=line.strip()
  else:
    node[colname] = line.strip()

  if count > 0 and colno == 2:
    rows[code] = node

  count = count + 1 
json.dump(rows, ofile)
END

