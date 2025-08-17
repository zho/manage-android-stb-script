#!/bin/bash

# Usage: ./check_playback.sh <STB_IP>
# Example: ./check_playback.sh 192.168.1.25

STB_IP=$1
PORT=5555

if [ -z "$STB_IP" ]; then
  echo "Usage: $0 <STB_IP>"
  exit 1
fi

echo "Connecting to STB $STB_IP..."
adb connect ${STB_IP}:${PORT} >/dev/null

echo "---- Checking Audio ----"
AUDIO=$(adb -s ${STB_IP}:${PORT} shell dumpsys media.audio_flinger | grep "AudioTrack" | grep -v "stopped")

if [ -n "$AUDIO" ]; then
  echo "✅ Audio: Playing"
else
  echo "❌ Audio: Not playing"
fi

echo "---- Checking Video ----"
VIDEO=$(adb -s ${STB_IP}:${PORT} shell dumpsys media.codec | grep -iE "video/avc|video/hevc|video/mp4v")

if [ -n "$VIDEO" ]; then
  echo "✅ Video: Playing"
else
  echo "❌ Video: Not playing"
fi
