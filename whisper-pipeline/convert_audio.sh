#!/bin/bash

# Source logger
source /app/logger.sh

VIDEO_FILE="$1"

if [ -z "$VIDEO_FILE" ]; then
    log_error "No video file provided for audio conversion"
    exit 1
fi

# Load paths from config
AUDIO_DIR=$(jq -r '.paths.audio' /app/config.json)

# Extract filename without path and extension
FILENAME=$(basename "$VIDEO_FILE")
FILENAME_NO_EXT="${FILENAME%.*}"
AUDIO_FILE="$AUDIO_DIR/$FILENAME_NO_EXT.mp3"

log_info "Converting video to audio: $VIDEO_FILE -> $AUDIO_FILE"

# Create audio directory if it doesn't exist
mkdir -p "$AUDIO_DIR"

# Convert video to audio using ffmpeg
ffmpeg -i "$VIDEO_FILE" -q:a 0 -map a "$AUDIO_FILE" -y 2> /app/data/logs/ffmpeg_error.log

if [ $? -eq 0 ]; then
    log_success "Audio extraction successful: $AUDIO_FILE"
    exit 0
else
    log_error "Failed to extract audio from $VIDEO_FILE. See logs for details."
    exit 1
fi
