#!/bin/bash

TMP_DIR=.tmp
RUNNER_DIR=$TMP_DIR/runner
BRANCH="master"

mkdir -p $TMP_DIR

has_runner_branch=false

for var in "$@"; do
  if [ $has_runner_branch = true ]; then
    BRANCH="$var"
    has_runner_branch=false
  fi
  if [ "$var" == "--branch" ]; then
    has_runner_branch=true
    continue
  fi
done

if [ ! -d "$RUNNER_DIR" ]; then
  echo "$RUNNER_DIR doesnt exist"
  echo "Cloning test runner repository"
  git clone -q https://github.com/cta-wave/dpctf-test-runner $RUNNER_DIR
fi
echo "Checking out branch $BRANCH"
git -C $RUNNER_DIR checkout -q $BRANCH --

