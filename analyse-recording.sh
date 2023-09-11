#!/bin/sh

if ! $(docker info > /dev/null 2>&1); then
    echo "Docker is not running.";
    exit 1;
fi

if [[ "$(docker images -q dpctf-dof:latest 2> /dev/null)" == "" ]]; then
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

docker run --rm --name device-observation-framework \
-v "$dirname":/usr/app/recordings \
-e RECORDING_FILENAME="$filename" \
-v ./observation-config.ini:/usr/app/device-observation-framework/config.ini \
dpctf-dof:latest
