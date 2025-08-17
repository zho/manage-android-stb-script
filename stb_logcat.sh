#!/bin/bash

if [[ $# -eq 0 ]]; then
  echo "Usage: $0 <ip>"
  echo "Example: $0 192.168.1.10"
  exit 1
fi

IP="$1"

echo "Running logcat for $IP:5555 ..."
adb -s "$IP:5555" logcat

