#!/bin/bash

echo "Downloading content ..."
python3 ./download-content.py https://raw.githubusercontent.com/cta-wave/Test-Content/75eecb6a5a558fddf8bbdd68c6a5b3675be55f0c/database.json content

#echo ""
#echo "Importing DPCTF tests ..."
#git clone https://github.com/cta-wave/dpctf-tests dpctf
#mv dpctf/generated/* tests
#if [ ! -f tests/test-config.json ]; then
#mv dpctf/test-config.json tests
#fi
#rm -rf dpctf
