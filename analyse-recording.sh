#!/bin/bash

if ! $(docker info > /dev/null 2>&1); then
    echo "Unable to access docker. (Not running or no permissions?)";
    echo "For more help see: https://docs.docker.com/engine/install/linux-postinstall/";
    exit 1;
fi

if [ "$(docker images -q dpctf-dof:latest 2> /dev/null)" == "" ]; then
    echo "DOF image not found! Please build it using:";
    echo "./build-dof.sh";
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
config_dir=$(realpath "./configuration");
args=""
if test -f "$observation_ini"; then
    args="$args -v "$observation_ini":/usr/app/device-observation-framework/config.ini"
fi
if test -d "$config_dir"; then
    args="$args -v "$config_dir":/usr/app/device-observation-framework/configuration"
fi

shift

docker run -it --rm \
-v "$dirname":/usr/app/recordings \
-v "$(pwd)/observation_logs":/usr/app/device-observation-framework/logs \
-v "$(pwd)/observation_results":/usr/app/device-observation-framework/results \
-e RECORDING_FILENAME="$filename" \
$args \
dpctf-dof:latest $@
