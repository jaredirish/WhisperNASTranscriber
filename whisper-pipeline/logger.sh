#!/bin/bash

# Create log directory if it doesn't exist
mkdir -p /app/data/logs

LOG_FILE="/app/data/logs/whisper-pipeline.log"
ERROR_LOG_FILE="/app/data/logs/error.log"

# Color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Timestamp function
timestamp() {
  date +"%Y-%m-%d %H:%M:%S"
}

# Logging functions
log_info() {
    local message="$1"
    echo -e "${BLUE}[INFO]${NC} $(timestamp) - $message"
    echo "[INFO] $(timestamp) - $message" >> "$LOG_FILE"
}

log_success() {
    local message="$1"
    echo -e "${GREEN}[SUCCESS]${NC} $(timestamp) - $message"
    echo "[SUCCESS] $(timestamp) - $message" >> "$LOG_FILE"
}

log_warning() {
    local message="$1"
    echo -e "${YELLOW}[WARNING]${NC} $(timestamp) - $message"
    echo "[WARNING] $(timestamp) - $message" >> "$LOG_FILE"
}

log_error() {
    local message="$1"
    echo -e "${RED}[ERROR]${NC} $(timestamp) - $message"
    echo "[ERROR] $(timestamp) - $message" >> "$LOG_FILE"
    echo "[ERROR] $(timestamp) - $message" >> "$ERROR_LOG_FILE"
}
