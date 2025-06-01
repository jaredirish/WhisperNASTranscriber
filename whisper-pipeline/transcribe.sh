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

# Check for whisper executable (prefer new whisper-cli over deprecated main)
WHISPER_EXEC=""
if [ -f "./build/bin/whisper-cli" ]; then
    WHISPER_EXEC="./build/bin/whisper-cli"
elif [ -f "./whisper-cli" ]; then
    WHISPER_EXEC="./whisper-cli"
elif [ -f "./build/bin/main" ]; then
    WHISPER_EXEC="./build/bin/main"
elif [ -f "./main" ]; then
    WHISPER_EXEC="./main"
elif [ -f "./build/main" ]; then
    WHISPER_EXEC="./build/main"
else
    log_info "Whisper executable not found. Building..."
    make
    
    # Check again after build
    if [ -f "./build/bin/whisper-cli" ]; then
        WHISPER_EXEC="./build/bin/whisper-cli"
    elif [ -f "./whisper-cli" ]; then
        WHISPER_EXEC="./whisper-cli"
    elif [ -f "./build/bin/main" ]; then
        WHISPER_EXEC="./build/bin/main"
    elif [ -f "./main" ]; then
        WHISPER_EXEC="./main"
    elif [ -f "./build/main" ]; then
        WHISPER_EXEC="./build/main"
    else
        log_error "Failed to build whisper.cpp - executable not found after build"
        exit 1
    fi
fi

log_info "Using whisper executable: $WHISPER_EXEC"

# Use different parameters based on executable type
if [[ "$WHISPER_EXEC" == *"whisper-cli"* ]]; then
    # New whisper-cli parameters
    $WHISPER_EXEC -m "$MODEL_PATH" -f "$AUDIO_FILE" -t $THREADS $LANG_PARAM -otxt -ovtt -osrt -oj
else
    # Old main executable parameters
    $WHISPER_EXEC -m "$MODEL_PATH" -f "$AUDIO_FILE" -t $THREADS $LANG_PARAM -otxt -ovtt -osrt -ojson
fi

# Check which output files were created and move them
TRANSCRIPT_SUCCESS=false

if [ -f "$AUDIO_FILE.txt" ]; then
    mv "$AUDIO_FILE.txt" "$TRANSCRIPT_FILE"
    TRANSCRIPT_SUCCESS=true
    log_info "Moved TXT transcript to $TRANSCRIPT_FILE"
fi

if [ -f "$AUDIO_FILE.vtt" ]; then
    mv "$AUDIO_FILE.vtt" "$TRANSCRIPT_VTT"
    log_info "Moved VTT transcript to $TRANSCRIPT_VTT"
fi

if [ -f "$AUDIO_FILE.srt" ]; then
    mv "$AUDIO_FILE.srt" "$TRANSCRIPT_SRT"
    log_info "Moved SRT transcript to $TRANSCRIPT_SRT"
fi

# Handle both .json and .json output files depending on whisper version
if [ -f "$AUDIO_FILE.json" ]; then
    mv "$AUDIO_FILE.json" "$TIMESTAMP_FILE"
    log_info "Moved JSON transcript to $TIMESTAMP_FILE"
fi

if [ "$TRANSCRIPT_SUCCESS" = true ] && [ -f "$TRANSCRIPT_FILE" ]; then
    log_success "Transcription successful: $TRANSCRIPT_FILE"
    
    # Count words in transcript
    WORD_COUNT=$(wc -w < "$TRANSCRIPT_FILE")
    log_info "Transcript contains $WORD_COUNT words"
    
    exit 0
else
    log_error "Failed to transcribe $AUDIO_FILE - no output files generated"
    log_error "Expected files: $AUDIO_FILE.txt, $AUDIO_FILE.vtt, $AUDIO_FILE.srt"
    # List what files actually exist in the audio directory for debugging
    log_error "Files in audio directory: $(ls -la $(dirname "$AUDIO_FILE"))"
    exit 1
fi
