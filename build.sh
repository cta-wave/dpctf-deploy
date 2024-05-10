#!/bin/bash

if ! $(docker info > /dev/null 2>&1); then
    echo "Unable to access docker. (Not running or no permissions?)";
    echo "For more help see: https://docs.docker.com/engine/install/linux-postinstall/";
    exit 1;
fi

reload_runner=false
reload_tests=false
tests_branch="master"
has_tests_branch=false

for var in "$@"; do
  if [ $has_tests_branch = true ]; then
    tests_branch="$var"
    has_tests_branch=false
  fi

  if [ "$var" == "--reload-runner" ]; then
    reload_runner=true
  elif [ "$var" == "--reload-tests" ]; then
    reload_tests=true
  elif [ "$var" == "--tests-branch" ]; then
    has_tests_branch=true
  fi
done

args=""

if [ ! -d "cache" ]; then
  mkdir cache
fi

touch cache/runner-rev.txt
touch cache/tests-rev.txt

if [ $reload_runner = true ]; then
  #args="$args --build-arg runner-rev=\"$(date | sed "s/ //g")\""
  date >> cache/runner-rev.txt
fi

if [ $reload_tests = true ]; then
  #args="$args --build-arg tests-rev=\"$(date | sed "s/ //g")\""
  date >> cache/tests-rev.txt
fi

docker build --network="host" --build-arg commit=$1 --build-arg testsbranch="$tests_branch" $args -t dpctf:$2 .
