#!/bin/bash

TMP_DIR=.tmp
TESTS_REPO_DIR=$TMP_DIR/dpctf-tests
TESTS_DIR="$TMP_DIR/tests"
TESTS_BRANCH="master"

mkdir -p $TMP_DIR

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

if [ ! -d "$TESTS_REPO_DIR" ]; then
  echo "Cloning tests repository"
  git clone -q https://github.com/cta-wave/dpctf-tests.git $TESTS_REPO_DIR
fi
git -C $TESTS_REPO_DIR checkout -q $TESTS_BRANCH --

rm -rf $TESTS_DIR 2>/dev/null
cp -r $TESTS_REPO_DIR/generated $TESTS_DIR
cp    $TESTS_REPO_DIR/test-config.json $TESTS_DIR
cp    $TESTS_REPO_DIR/test-subsets.json $TESTS_DIR

