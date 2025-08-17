#!/bin/bash
STB_IP=$1

if [ -z "$STB_IP" ]; then
  echo "Usage: $0 <STB_IP>"
  exit 1
fi

echo "Connecting to STB $STB_IP..."
adb connect $STB_IP:5555 >/dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "❌ Failed to connect to $STB_IP"
  exit 1
fi

echo "========================================="
echo "   🎬 Streaming Diagnostic Report"
echo "   Target: $STB_IP"
echo "========================================="

echo ""
echo "---- 🔊 Audio ----"
AUDIO=$(adb -s $STB_IP:5555 shell dumpsys audio | grep -i "state:started")
if [ -n "$AUDIO" ]; then
  echo "✅ Audio: Playing"
else
  echo "❌ Audio: Not playing"
fi

echo ""
echo "---- 🎥 Video ----"
SURFACE=$(adb -s $STB_IP:5555 shell dumpsys SurfaceFlinger | grep -i "SurfaceView" | head -n 1)
if [ -n "$SURFACE" ]; then
  echo "✅ Video Surface active: $SURFACE"
else
  echo "❌ Video: No active surface"
fi

echo ""
echo "---- 📉 Playback Stats ----"
CODEC=$(adb -s $STB_IP:5555 shell dumpsys media.codec | grep -iE "Frames|Dropped|frame-rate" | head -n 20)
if [ -n "$CODEC" ]; then
  echo "$CODEC"
else
  PLAYER=$(adb -s $STB_IP:5555 shell dumpsys media.player | grep -iE "Frames|Dropped|Speed" | head -n 20)
  if [ -n "$PLAYER" ]; then
    echo "$PLAYER"
  else
    echo "⚠️  No codec/player stats found"
  fi
fi

echo ""
echo "---- 📦 Responsible App ----"
FOREGROUND=$(adb -s $STB_IP:5555 shell dumpsys activity activities | grep mResumedActivity | awk '{print $4}')
if [ -n "$FOREGROUND" ]; then
  echo "▶️ Foreground app: $FOREGROUND"
else
  echo "⚠️  Could not detect foreground app"
fi

PLAYBACK_APPS=$(adb -s $STB_IP:5555 shell dumpsys media.session | grep "package" | uniq)
if [ -n "$PLAYBACK_APPS" ]; then
  echo "🎶 Active media sessions:"
  echo "$PLAYBACK_APPS"
else
  echo "⚠️  No active media sessions found"
fi

echo ""
echo "---- 🎞️ Codec Detection (VLC / ExoPlayer) ----"
CODEC_LOGS=$(adb -s $STB_IP:5555 logcat -d -t 200 | grep -E "VLC|libvlc|ExoPlayerImpl|MediaCodecRenderer|ACodec")
if [ -n "$CODEC_LOGS" ]; then
  echo "$CODEC_LOGS" | sed 's/^/   /'
else
  echo "⚠️  No codec information detected (maybe not logged recently)"
fi

# Clear logs after reading to avoid repeated output on next run
adb -s $STB_IP:5555 logcat -c >/dev/null 2>&1

echo ""
echo "========================================="
echo "✅ Diagnostic Complete"
echo "========================================="
