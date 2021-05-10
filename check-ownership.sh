#!/bin/bash

ownership=$(stat -c%u:%g $1);
permissions=$(stat -c%A $1);

if [ "$ownership" != "1000:1000" ] || [[ $permissions != *"w"* ]]; then
  echo;
  echo -e "\e[1;31m";
  echo "=== ERROR ================================================================"
  echo "= Ownership or permissions of results directory not properly configured. ="
  echo "= Set ownership to 1000:1000 and make directory writable!                ="
  echo "==========================================================================";
  echo -e "\e[0m";
  echo;
  exit 1;
fi
