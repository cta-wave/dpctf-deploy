#!/bin/bash

docker build --build-arg commit=$1 --build-arg runner-rev=$4 --build-arg tests-rev=$3 -t dpctf:$2 .
