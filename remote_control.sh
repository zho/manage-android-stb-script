#!/bin/bash

# Usage: ./remote_control.sh <adb command>
# Example: ./remote_control.sh reboot
# Example: ./remote_control.sh "install -r myapp.apk"

if [[ $# -eq 0 ]]; then
  echo "Usage: $0 <adb command>"
  exit 1
fi

COMMAND="$*"

# Get list of connected STBs
STBS=$(adb devices | awk 'NR>1 && $2=="device"{print $1}')

if [[ -z "$STBS" ]]; then
  echo "No connected STBs found. Please run adb connect first."
  exit 1
fi

for stb in $STBS; do
  echo ">>> Running: adb -s $stb $COMMAND"
  adb -s "$stb" $COMMAND
done

