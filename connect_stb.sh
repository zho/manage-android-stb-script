#!/bin/bash

STB_FILE="stb_list.txt"

if [[ ! -f "$STB_FILE" ]]; then
  echo "STB list not found. Please run the scan script first."
  exit 1
fi

TMP_FILE=$(mktemp)

while read -r ip; do
  [[ -z "$ip" ]] && continue

  echo "Connecting to $ip..."
  adb disconnect "$ip:5555" >/dev/null 2>&1
  adb connect "$ip:5555" >/dev/null 2>&1

  # Check if connected successfully
  if adb devices | grep -q "$ip:5555.*device"; then
    echo "$ip" >> "$TMP_FILE"
    echo "✅ $ip connected"
  else
    echo "❌ $ip offline (removed from list)"
  fi
done < "$STB_FILE"

# Replace original list with only online STBs
mv "$TMP_FILE" "$STB_FILE"

echo
echo "Active STBs:"
cat "$STB_FILE"

