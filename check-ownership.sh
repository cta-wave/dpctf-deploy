#!/bin/bash

ownership=$(stat -c%u:%g /home/ubuntu/DPCTF/results);

if [ "$ownership" != "1000:1000" ]; then
  echo;
  echo -e "\e[1;31m";
  echo "=== WARNING ==============================================="
  echo "= Ownership of results directory not properly configured. ="
  echo "= Set ownership to 1000:1000 to avoid misbehavior!        ="
  echo "===========================================================";
  echo -e "\e[0m";
  echo;
fi
