#!/bin/bash

# Initialize and set up environment
source /app/logger.sh

log_info "Starting whisper-pipeline container"

# Create necessary directories if they don't exist
mkdir -p /app/data/videos
mkdir -p /app/data/audio
mkdir -p /app/data/transcripts
mkdir -p /app/data/models
mkdir -p /app/data/logs

# Download model if it doesn't exist
/app/download_model.sh

# Start monitoring for new videos
log_info "Starting video monitoring service"
/app/monitor.sh &

# Keep container running
tail -f /dev/null
