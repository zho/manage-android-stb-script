#!/bin/bash
# Usage: ./check_playback.sh <stb_ip>
# Example: ./check_playback.sh 192.168.1.50

STB_IP=$1

if [ -z "$STB_IP" ]; then
  echo "Usage: $0 <stb_ip>"
  exit 1
fi

echo "Checking playback status on STB: $STB_IP"

# Make sure we are connected
adb connect $STB_IP:5555 >/dev/null

echo "---- AUDIO STATUS ----"
AUDIO_STATE=$(adb -s $STB_IP:5555 shell dumpsys media.audio_flinger | grep -A 2 "Track" | grep "state: ACTIVE")

if [ -n "$AUDIO_STATE" ]; then
  echo "Audio: PLAYING"
else
  echo "Audio: STOPPED"
fi

echo "---- VIDEO STATUS ----"
# Get frame timestamps from SurfaceFlinger
LATENCY=$(adb -s $STB_IP:5555 shell dumpsys SurfaceFlinger --latency 0 | head -n 5 | tail -n 3)

# Extract frame intervals (nanoseconds)
DIFF=$(echo "$LATENCY" | awk 'NR==2 {diff=$1-prev; prev=$1} NR>2 {d=$1-prev; prev=$1} END {print d}')

if [ "$DIFF" != "" ] && [ "$DIFF" -gt 0 ]; then
  echo "Video: RENDERING (frames updating)"
else
  echo "Video: NOT RENDERING"
fi

echo "---- CODEC INFO ----"
adb -s $STB_IP:5555 shell dumpsys media.codec | grep -i "OMX" | head -n 10
