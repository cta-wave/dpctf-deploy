#!/bin/bash

if ! [ "$(ls -A $1)" ]; then
  echo;
  echo -e "\e[1;31m";
  echo "=== ERROR ==========================="
  echo "= No content found. Aborting start. ="
  echo "=====================================";
  echo -e "\e[0m";
  echo;
  exit 1;
fi
