#!/bin/bash

mkdir .tmp/

TESTS_REPO_DIR=.tmp/fsmts-tests
TESTS_DIR=".tmp/tests"
TESTS_BRANCH="master"

has_tests_branch=false

for var in "$@"; do
  if [ $has_tests_branch = true ]; then
    TESTS_BRANCH="$var"
    has_tests_branch=false
  fi

  if [ "$var" == "--tests-branch" ]; then
    has_tests_branch=true
  fi
done

git clone -q https://github.com/cta-wave/dpctf-tests.git $TESTS_REPO_DIR
git -C $TESTS_REPO_DIR checkout -q $TESTS_BRANCH

mv $TESTS_REPO_DIR/generated $TESTS_DIR
mv $TESTS_REPO_DIR/test-config.json $TESTS_DIR
mv $TESTS_REPO_DIR/test-subsets.json $TESTS_DIR

