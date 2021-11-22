#!/bin/bash

echo "Downloading content ..."
./download-content.py https://raw.githubusercontent.com/cta-wave/Test-Content/d04389e031d0179d1232babe97ef8d05fa98efc2/database.json content

#echo ""
#echo "Importing DPCTF tests ..."
#git clone https://github.com/cta-wave/dpctf-tests dpctf
#mv dpctf/generated/* tests
#if [ ! -f tests/test-config.json ]; then
  #mv dpctf/test-config.json tests
#fi
#rm -rf dpctf
