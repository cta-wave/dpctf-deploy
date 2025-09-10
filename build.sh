#!/bin/bash

if ! $(docker info > /dev/null 2>&1); then
    echo "Unable to access docker. (Not running or no permissions?)";
    echo "For more help see: https://docs.docker.com/engine/install/linux-postinstall/";
    exit 1;
fi

reload_runner=false
reload_tests=false
tests_dir=".tmp/tests"
has_tests_dir=false
test_runner_commit="v2.2.0"
image_tag="v3.0.0"
argument_count=0

for var in "$@"; do
  if [ $has_tests_dir = true ]; then
    tests_dir="$var"
    has_tests_dir=false
  fi

  if [[ "$var" != --* ]]; then
    if [[ "$argument_count" -eq 0 ]]; then
      test_runner_commit="$var"
      argument_count=1
    elif [[ "$argument_count" -eq 1 ]]; then
      image_tag="$var"
      argument_count=2
    fi
  fi
  if [ "$var" == "--reload-runner" ]; then
    reload_runner=true
  elif [ "$var" == "--tests-dir" ]; then
    has_tests_dir=true
  fi
done

if [ ! -d ".cache" ]; then
  mkdir .cache
fi

touch .cache/runner-rev.txt
touch .cache/tests-rev.txt

if [ $reload_runner = true ]; then
  date >> .cache/runner-rev.txt
fi

if [ $reload_tests = true ]; then
  date >> .cache/tests-rev.txt
fi

docker build --network="host" --build-arg commit=$test_runner_commit --build-arg tests_dir="$tests_dir" -t dpctf:$image_tag .
