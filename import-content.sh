#!/bin/bash

CONTENT_VERSION="${1:-master}"
CONTENT_URL="https://raw.githubusercontent.com/cta-wave/Test-Content/${CONTENT_VERSION}/database.json"

if ! $(docker info > /dev/null 2>&1); then
    echo "Unable to access docker. (Not running or no permissions?)";
    echo "For more help see: https://docs.docker.com/engine/install/linux-postinstall/";
    exit 1;
fi

echo ""
echo "DATA SIZE WARNING: This script will download a lot of data!"
echo ""

echo "Downloading content from ${CONTENT_VERSION} ..."
docker run -it --rm --name import-content --network host -v "$(pwd)":/usr/src/import-content -w /usr/src/import-content python:3.8 python3 ./download-content.py "${CONTENT_URL}" content
