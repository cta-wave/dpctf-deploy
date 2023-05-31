#!/bin/bash

echo "Downloading content ..."
python3 ./download-content.py https://raw.githubusercontent.com/cta-wave/Test-Content/6a363ca9225f41cc3f03d0bb286f99647f89d04b/database.json content

#echo ""
#echo "Importing DPCTF tests ..."
#git clone https://github.com/cta-wave/dpctf-tests dpctf
#mv dpctf/generated/* tests
#if [ ! -f tests/test-config.json ]; then
  #mv dpctf/test-config.json tests
#fi
#rm -rf dpctf
