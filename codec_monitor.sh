#!/bin/bash
# Usage: ./codec_monitor.sh <device_id>
DEVICE=$1

if [ -z "$DEVICE" ]; then
  echo "Usage: $0 <device_id>"
  exit 1
fi

echo "=== Active Media Codecs on $DEVICE ==="

# ambil semua codec instance
adb -s $DEVICE shell dumpsys media.codec | awk '
/Codec/ {codec=$0}
/pid/ {pid=$2; uid=$4; print codec, pid, uid}
' | while read line; do
    codec=$(echo "$line" | awk '{print $2}')
    pid=$(echo "$line" | awk '{print $4}')
    uid=$(echo "$line" | awk '{print $6}')

    # cari package name dari pid
    package=$(adb -s $DEVICE shell ps -A | awk -v p=$pid '$2==p {print $9}')
    if [ -z "$package" ]; then
        package=$(adb -s $DEVICE shell cmd package resolve-uid $uid 2>/dev/null | head -n 1)
    fi

    echo ""
    echo "App: $package"
    echo "Codec: $codec (pid=$pid uid=$uid)"

    # cek info video surface untuk fps & drop frames
    sf_info=$(adb -s $DEVICE shell dumpsys SurfaceFlinger --latency | head -n 5)
    fps=$(echo "$sf_info" | grep "fps" | awk '{print $2}')
    dropped=$(echo "$sf_info" | grep "dropped" | awk '{print $2}')
    if [ -n "$fps" ]; then
        echo "Video: ${fps} fps, dropped frames=${dropped}"
    fi

    # cek audio track status
    audio=$(adb -s $DEVICE shell dumpsys media.audio_flinger | grep -A3 "Client $pid")
    if [ -n "$audio" ]; then
        echo "Audio: ACTIVE"
    else
        echo "Audio: idle"
    fi
done
