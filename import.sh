#!/bin/bash

echo "Downloading content ..."
./download-content.py https://dash.akamaized.net/WAVE/vectors/database.json content

#echo ""
#echo "Importing DPCTF tests ..."
#git clone https://github.com/cta-wave/dpctf-tests dpctf
#mv dpctf/generated/* tests
#if [ ! -f tests/test-config.json ]; then
  #mv dpctf/test-config.json tests
#fi
#rm -rf dpctf
