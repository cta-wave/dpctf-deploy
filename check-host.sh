#!/bin/bash

host_ip=$(sed -En 's/\s*"host_override"\s*:\s*"([^"]*)".*/\1/p' $1)

if [[ -z "$host_ip" ]]; then
  echo "No host IP provided."
  exit 0
fi

echo "Checking host_override IP '$host_ip' ..."
ip_regex="[\d+\.\d+\.\d+\.\d+]"
if [[ $host_ip =~ $ip_regex ]]; then
  if ! ping -c 1 "$host_ip" >/dev/null; then
    echo
    echo -e "\e[1;31m"
    echo "=== WARNING ====================="
    echo "= Provided host is unreachable. ="
    echo "================================="
    echo -e "\e[0m"
    echo
    exit 0
  fi
fi
