#!/bin/bash

echo "Downloading content ..."
./download-content.py https://raw.githubusercontent.com/cta-wave/Test-Content/587cef1f7d531bb9326c21ca11cad95454d62621/database.json content

#echo ""
#echo "Importing DPCTF tests ..."
#git clone https://github.com/cta-wave/dpctf-tests dpctf
#mv dpctf/generated/* tests
#if [ ! -f tests/test-config.json ]; then
  #mv dpctf/test-config.json tests
#fi
#rm -rf dpctf
