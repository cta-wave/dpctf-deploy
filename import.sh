#!/bin/bash

docker run -it --rm --name import-content -v $(pwd):/usr/src/import-content -w /usr/src/import-content python:3.8 sh ./download-content.sh