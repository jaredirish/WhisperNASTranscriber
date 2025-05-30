#!/bin/bash

# Source logger
source /app/logger.sh

AUDIO_FILE="$1"

if [ -z "$AUDIO_FILE" ]; then
    log_error "No audio file provided for transcription"
    exit 1
fi

# Load configuration
MODEL_SIZE=${MODEL_SIZE:-base}
LANGUAGE=${LANGUAGE:-}
THREADS=${THREADS:-4}
DEVICE=${DEVICE:-cpu}

TRANSCRIPTS_DIR=$(jq -r '.paths.transcripts' /app/config.json)
MODEL_PATH="/app/data/models/ggml-$MODEL_SIZE.bin"

# Extract filename without path and extension
FILENAME=$(basename "$AUDIO_FILE")
FILENAME_NO_EXT="${FILENAME%.*}"
TRANSCRIPT_FILE="$TRANSCRIPTS_DIR/$FILENAME_NO_EXT.txt"
TRANSCRIPT_VTT="$TRANSCRIPTS_DIR/$FILENAME_NO_EXT.vtt"
TRANSCRIPT_SRT="$TRANSCRIPTS_DIR/$FILENAME_NO_EXT.srt"
TIMESTAMP_FILE="$TRANSCRIPTS_DIR/$FILENAME_NO_EXT.json"

# Create transcripts directory if it doesn't exist
mkdir -p "$TRANSCRIPTS_DIR"

log_info "Transcribing audio: $AUDIO_FILE with model: $MODEL_SIZE"

# Prepare language parameter if specified
LANG_PARAM=""
if [ ! -z "$LANGUAGE" ]; then
    LANG_PARAM="-l $LANGUAGE"
fi

# Run whisper.cpp
cd /app/whisper.cpp
if [ ! -f "./main" ]; then
    log_error "Whisper.cpp main executable not found. Attempting to build..."
    make
    if [ ! -f "./main" ]; then
        log_error "Failed to build whisper.cpp"
        exit 1
    fi
fi

./main -m "$MODEL_PATH" -f "$AUDIO_FILE" -t $THREADS $LANG_PARAM -otxt -ovtt -osrt -ojson

# Move output files to transcripts directory
mv "$AUDIO_FILE.txt" "$TRANSCRIPT_FILE"
mv "$AUDIO_FILE.vtt" "$TRANSCRIPT_VTT"
mv "$AUDIO_FILE.srt" "$TRANSCRIPT_SRT"
mv "$AUDIO_FILE.json" "$TIMESTAMP_FILE"

if [ $? -eq 0 ] && [ -f "$TRANSCRIPT_FILE" ]; then
    log_success "Transcription successful: $TRANSCRIPT_FILE"
    
    # Count words in transcript
    WORD_COUNT=$(wc -w < "$TRANSCRIPT_FILE")
    log_info "Transcript contains $WORD_COUNT words"
    
    exit 0
else
    log_error "Failed to transcribe $AUDIO_FILE"
    exit 1
fi
