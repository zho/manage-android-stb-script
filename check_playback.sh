#!/bin/bash

DEVICE_IP=$1
ADB="adb -s $DEVICE_IP:5555"

if [ -z "$DEVICE_IP" ]; then
    echo "Usage: $0 <device_ip>"
    exit 1
fi

echo "Checking playback status on STB: $DEVICE_IP"

# --- FOREGROUND APP & ACTIVITY ---
APP=$($ADB shell dumpsys activity activities | grep mResumedActivity)
PACKAGE=$(echo "$APP" | sed -n 's/.* \(.*\)\/.*/\1/p')
PID=$($ADB shell pidof $PACKAGE)

echo "App: $APP"

# --- FRAMEWORK DETECTION ---
FRAMEWORK="Unknown"

if echo "$APP" | grep -iq "vlc"; then
    FRAMEWORK="VLC"
elif echo "$APP" | grep -iq "exo"; then
    FRAMEWORK="ExoPlayer"
elif echo "$APP" | grep -iq "media3"; then
    FRAMEWORK="Media3"
else
    LIBS=$($ADB shell cat /proc/$PID/maps | grep -iE "libvlc|exo|media3")
    if echo "$LIBS" | grep -iq "libvlc"; then
        FRAMEWORK="VLC"
    elif echo "$LIBS" | grep -iq "exo"; then
        FRAMEWORK="ExoPlayer"
    elif echo "$LIBS" | grep -iq "media3"; then
        FRAMEWORK="Media3"
    fi
fi
echo "Framework: $FRAMEWORK"

# --- AUDIO STATUS WITH CODEC ---
AUDIO="UNKNOWN"
AUDIO_CODEC="Unknown"

if [ "$FRAMEWORK" = "VLC" ]; then
    # Infer by CPU usage
    CPU=$($ADB shell top -n 1 | grep $PID | awk '{print $9}')
    CPU=$(echo $CPU | sed 's/%//') # remove %
    if (( $(echo "$CPU > 0.5" | bc -l) )); then
        AUDIO="PLAYING"
    else
        AUDIO="STOPPED"
    fi
    # Try to get codec from VLC logcat if available
    LOGS_AUDIO=$($ADB logcat -d -t 500 | grep -i "VLC/AudioDecoder")
    if [ -n "$LOGS_AUDIO" ]; then
        AUDIO_CODEC=$(echo "$LOGS_AUDIO" | tail -n 1 | awk -F':' '{print $NF}' | sed 's/OMX.*\.//; s/ //g')
    fi
else
    AUDIO_STATE=$($ADB shell dumpsys media_session | grep -i "PlaybackState")
    if echo "$AUDIO_STATE" | grep -iq "STATE_PLAYING"; then
        AUDIO="PLAYING"
        CODEC_LINE=$($ADB shell dumpsys media.player | grep -i "audioCodecName" | head -n 1)
        AUDIO_CODEC=$(echo "$CODEC_LINE" | awk -F'=' '{print $2}' | sed 's/ //g')
    else
        AUDIO="STOPPED"
    fi
fi
echo "Audio: $AUDIO ($AUDIO_CODEC)"

# --- VIDEO STATUS WITH CODEC ---
VIDEO="UNKNOWN"
VIDEO_CODEC="Unknown"

if [ "$FRAMEWORK" = "VLC" ]; then
    # Infer by CPU usage
    CPU=$($ADB shell top -n 1 | grep $PID | awk '{print $9}')
    CPU=$(echo $CPU | sed 's/%//')
    if (( $(echo "$CPU > 0.5" | bc -l) )); then
        VIDEO="RENDERING"
    else
        VIDEO="NOT RENDERING"
    fi
    # Try to get codec from VLC logcat if available
    LOGS_VIDEO=$($ADB logcat -d -t 500 | grep -i "VLC/VideoDecoder")
    if [ -n "$LOGS_VIDEO" ]; then
        VIDEO_CODEC=$(echo "$LOGS_VIDEO" | tail -n 1 | awk -F':' '{print $NF}' | sed 's/OMX.*\.//; s/ //g')
    fi
else
    VIDEO_STATE=$($ADB shell dumpsys media.player | grep -i "state=STARTED")
    if [ -n "$VIDEO_STATE" ]; then
        VIDEO="RENDERING"
        CODEC_LINE=$($ADB shell dumpsys media.player | grep -i "codecName" | head -n 1)
        VIDEO_CODEC=$(echo "$CODEC_LINE" | awk -F'=' '{print $2}' | sed 's/OMX.*\.//; s/ //g')
    else
        VIDEO="NOT RENDERING"
    fi
fi
echo "Video: $VIDEO ($VIDEO_CODEC)"

