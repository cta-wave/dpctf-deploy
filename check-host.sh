#!/bin/bash

host_ip=$(sed -En 's/\s*"host_override":\s?"([[:digit:]]+\.[[:digit:]]+\.[[:digit:]]+\.[[:digit:]]+)"/\1/p' $1);
echo "Checking host_override IP '$host_ip' ..."
ip_regex="[\d+\.\d+\.\d+\.\d+]"
if [[ $host_ip =~ $ip_regex ]]; then
  if ! ping -c 1 "$host_ip" > /dev/null; then
    echo;
    echo -e "\e[1;31m";
    echo "=== ERROR ========================================"
    echo "= Provided host_override IP seems to be invalid. ="
    echo "==================================================";
    echo -e "\e[0m";
    echo;
    exit 1;
  fi
fi
