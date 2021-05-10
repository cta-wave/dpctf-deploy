#!/bin/bash

reload_runner=false
reload_tests=false

for var in "$@"
do
  if [ "$var" == "--reload-runner" ]; then
    reload_runner=true;
  elif [ "$var" == "--reload-tests" ]; then
    reload_tests=true;
  fi
done

args=""

if [ $reload_runner = true ]; then
  args="$args --build-arg runner-rev=\"$(date | sed "s/ //g")\""
fi

if [ $reload_tests = true ]; then
  args="$args --build-arg tests-rev=\"$(date | sed "s/ //g")\""
fi

docker build --build-arg commit=$1 $args -t dpctf:$2 .
