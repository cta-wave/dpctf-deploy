#!/bin/bash

if ! $(docker info > /dev/null 2>&1); then
    echo "Unable to access docker. (Not running or no permissions?)";
    echo "For more help see: https://docs.docker.com/engine/install/linux-postinstall/";
    exit 1;
fi

reload_dof=false

for var in "$@"; do
  if [ "$var" == "--reload-dof" ]; then
    reload_dof=true
  fi
done

args=""

if [ $reload_dof = true ]; then
  args="$args --build-arg dof-rev=\"$(date | sed "s/ //g")\""
fi

docker build $args --file Dockerfile.dof -t dpctf-dof:v2.0.1 .
