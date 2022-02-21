#!/bin/bash

echo "Downloading content ..."
./download-content.py https://raw.githubusercontent.com/cta-wave/Test-Content/05c5987cf2ab218528c0e5bcde4d0a1cd09fb448/database.json content

#echo ""
#echo "Importing DPCTF tests ..."
#git clone https://github.com/cta-wave/dpctf-tests dpctf
#mv dpctf/generated/* tests
#if [ ! -f tests/test-config.json ]; then
  #mv dpctf/test-config.json tests
#fi
#rm -rf dpctf
