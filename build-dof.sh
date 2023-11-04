#!/bin/bash

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

docker build $args --file Dockerfile.dof -t dpctf-dof:latest .
