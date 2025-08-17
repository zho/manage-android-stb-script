#!/bin/bash

# Usage: ./scan_stb.sh <subnet>
# Example: ./scan_stb.sh 192.168.1.0/24

if [[ $# -eq 0 ]]; then
  echo "Usage: $0 <subnet>"
  echo "Example: $0 192.168.1.0/24"
  exit 1
fi

SUBNET="$1"
OUTPUT="stb_list.txt"

echo "Scanning subnet $SUBNET for STB (port 5555)..."

# Scan for port 5555 open, save only IPs
nmap -p 5555 --open "$SUBNET" -oG - | awk '/5555\/open/{print $2}' > "$OUTPUT"

if [[ -s "$OUTPUT" ]]; then
  echo "✅ Found STBs:"
  cat "$OUTPUT"
else
  echo "❌ No STBs found in $SUBNET"
fi

