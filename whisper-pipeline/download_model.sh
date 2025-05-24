#!/bin/bash

# Source logger
source /app/logger.sh

# Set default model size if not provided
MODEL_SIZE=${MODEL_SIZE:-base}

# Load model information from config.json
MODEL_URL=$(jq -r ".models.\"$MODEL_SIZE\".url" /app/config.json)
MODEL_SIZE_INFO=$(jq -r ".models.\"$MODEL_SIZE\".size" /app/config.json)
MODEL_PATH="/app/data/models/ggml-$MODEL_SIZE.bin"

# Check if model already exists
if [ -f "$MODEL_PATH" ]; then
    log_info "Model $MODEL_SIZE already exists at $MODEL_PATH"
else
    log_info "Downloading $MODEL_SIZE model (approximately $MODEL_SIZE_INFO)..."
    wget -O "$MODEL_PATH" "$MODEL_URL"
    
    if [ $? -eq 0 ]; then
        log_success "Model downloaded successfully to $MODEL_PATH"
    else
        log_error "Failed to download model. Please check your internet connection and try again."
        exit 1
    fi
fi
