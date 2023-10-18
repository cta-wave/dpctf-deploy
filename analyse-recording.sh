#!/bin/bash

if ! $(docker info > /dev/null 2>&1); then
    echo "Unable to access docker. (Not running or no permissions?)";
    exit 1;
fi

if [ "$(docker images -q dpctf-dof:latest 2> /dev/null)" == "" ]; then
    echo "DOF image not found! Please build it using:";
    echo "docker build --file Dockerfile.dof -t dpctf-dof:latest .";
    exit 1;
fi

if [ -z "$1" ]; then
    echo "No video recording provided!";
    echo "analyse-recordings.sh <video-file>";
    exit 1;
fi

absolute_path=$(realpath "$1");
dirname=$(dirname "$absolute_path");
filename=$(basename "$absolute_path");

observation_ini=$(realpath "./observation-config.ini");

docker run -it --rm \
-v "$dirname":/usr/app/recordings \
-e RECORDING_FILENAME="$filename" \
-v "$observation_ini":/usr/app/device-observation-framework/config.ini \
-v "$(pwd)/logs":/usr/app/device-observation-framework/logs \
dpctf-dof:latest
