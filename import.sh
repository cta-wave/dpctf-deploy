#!/bin/bash

if ! $(docker info > /dev/null 2>&1); then
    echo "Unable to access docker. (Not running or no permissions?)";
    echo "For more help see: https://docs.docker.com/engine/install/linux-postinstall/";
    exit 1;
fi

docker run -it --rm --name import-content -v $(pwd):/usr/src/import-content -w /usr/src/import-content python:3.8 sh ./download-content.sh
