#!/bin/bash

# Source logger
source /app/logger.sh

VIDEO_FILE="$1"

if [ -z "$VIDEO_FILE" ]; then
    log_error "No video file provided"
    exit 1
fi

# Check if file exists
if [ ! -f "$VIDEO_FILE" ]; then
    log_error "Video file does not exist: $VIDEO_FILE"
    exit 1
fi

log_info "Processing video: $VIDEO_FILE"

# Extract filename without path and extension
FILENAME=$(basename "$VIDEO_FILE")
FILENAME_NO_EXT="${FILENAME%.*}"

# Convert video to audio
AUDIO_OUTPUT=$(/app/convert_audio.sh "$VIDEO_FILE")
AUDIO_EXIT_CODE=$?

if [ $AUDIO_EXIT_CODE -ne 0 ]; then
    log_error "Failed to convert video to audio: $VIDEO_FILE"
    exit 1
fi

log_success "Video converted to audio: $AUDIO_OUTPUT"

# Transcribe audio to text
/app/transcribe.sh "$AUDIO_OUTPUT"
TRANSCRIBE_EXIT_CODE=$?

if [ $TRANSCRIBE_EXIT_CODE -ne 0 ]; then
    log_error "Failed to transcribe audio: $AUDIO_OUTPUT"
    exit 1
fi

log_success "Processing complete for: $FILENAME"
