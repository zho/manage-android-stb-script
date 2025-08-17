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
AUDIO_DEVICE=$(adb -s ${STB_IP}:${PORT} shell dumpsys media.audio_flinger | grep -i "Device:" | head -n 1 | awk -F':' '{print $2}' | xargs)

if [ -n "$AUDIO" ]; then
  if [ -n "$AUDIO_DEVICE" ]; then
    echo "✅ Audio: Playing (Output: $AUDIO_DEVICE)"
  else
    echo "✅ Audio: Playing"
  fi
else
  echo "❌ Audio: Not playing"
fi

echo "---- Checking Video ----"
VIDEO=$(adb -s ${STB_IP}:${PORT} shell dumpsys media.codec | grep -iE "video/avc|video/hevc|video/mp4v")
VIDEO_CODEC=$(adb -s ${STB_IP}:${PORT} shell dumpsys media.codec | grep -i "name:" | grep -i "video" | awk -F'name:' '{print $2}' | xargs)

if [ -n "$VIDEO" ]; then
  if [ -n "$VIDEO_CODEC" ]; then
    echo "✅ Video: Playing (Codec:$VIDEO_CODEC)"
  else
    echo "✅ Video: Playing"
  fi
else
  echo "❌ Video: Not playing"
fi
