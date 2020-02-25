#!/bin/bash

docker build --build-arg commit=$1 -t dpctf:$2 .
