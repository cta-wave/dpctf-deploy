#!/bin/bash

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

if [ $reload_runner = true ]; then
  args="$args --build-arg runner-rev=\"$(date | sed "s/ //g")\""
fi

if [ $reload_tests = true ]; then
  args="$args --build-arg tests-rev=\"$(date | sed "s/ //g")\""
fi

docker build --network="host" --build-arg commit=$1 --build-arg testsbranch="$tests_branch" $args -t dpctf:$2 .
