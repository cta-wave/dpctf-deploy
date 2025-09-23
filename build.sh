#!/bin/bash

if ! $(docker info > /dev/null 2>&1); then
    echo "Unable to access docker. (Not running or no permissions?)";
    echo "For more help see: https://docs.docker.com/engine/install/linux-postinstall/";
    exit 1;
fi

image_name="dpctf"
image_tag="latest"
tests_dir=".tmp/tests"
runner_dir=".tmp/runner"

has_tests_dir=false
has_runner_dir=false

argument_count=0
argument1=""
argument2=""

for var in "$@"; do
  if [ $has_tests_dir = true ]; then
    tests_dir="$var"
    has_tests_dir=false
    continue
  fi
  if [ $has_runner_dir = true ]; then
    runner_dir="$var"
    has_runner_dir=false
    continue
  fi

  if [[ "$var" != --* ]]; then
    if [[ "$argument_count" -eq 0 ]]; then
      argument1="$var"
      argument_count=1
    elif [[ "$argument_count" -eq 1 ]]; then
      argument2="$var"
      argument_count=2
    fi
  fi
  if [ "$var" == "--runner-dir" ]; then
    has_runner_dir=true
  elif [ "$var" == "--tests-dir" ]; then
    has_tests_dir=true
  fi
done

if [[ "$argument_count" -eq 2 ]]; then
  image_name="$argument1"
  image_tag="$argument2"
fi

docker build \
  --network="host" \
  --build-arg tests_dir="$tests_dir" \
  --build-arg runner_dir="$runner_dir" \
  -t $image_name:$image_tag .
