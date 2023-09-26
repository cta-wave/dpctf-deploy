#!/bin/bash

echo "Downloading content ..."
python3 ./download-content.py https://raw.githubusercontent.com/cta-wave/Test-Content/d70a5fe66d699e2f8ed49b280f46a6ffddfb6b79/database.json content

#echo ""
#echo "Importing DPCTF tests ..."
#git clone https://github.com/cta-wave/dpctf-tests dpctf
#mv dpctf/generated/* tests
#if [ ! -f tests/test-config.json ]; then
#mv dpctf/test-config.json tests
#fi
#rm -rf dpctf
