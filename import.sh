#!/bin/bash

echo "Downloading content ..."
./download-content.py https://raw.githubusercontent.com/cta-wave/Test-Content/1197c7d793fefeeb2d3ecff2815c36f7e9e97581/database.json content

#echo ""
#echo "Importing DPCTF tests ..."
#git clone https://github.com/cta-wave/dpctf-tests dpctf
#mv dpctf/generated/* tests
#if [ ! -f tests/test-config.json ]; then
  #mv dpctf/test-config.json tests
#fi
#rm -rf dpctf
