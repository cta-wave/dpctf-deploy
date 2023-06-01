#!/bin/bash

echo "Downloading content ..."
python3 ./download-content.py https://raw.githubusercontent.com/cta-wave/Test-Content/f549bb49d5cc0cb97ee7697cf770711978874b9a/database.json content

#echo ""
#echo "Importing DPCTF tests ..."
#git clone https://github.com/cta-wave/dpctf-tests dpctf
#mv dpctf/generated/* tests
#if [ ! -f tests/test-config.json ]; then
  #mv dpctf/test-config.json tests
#fi
#rm -rf dpctf
