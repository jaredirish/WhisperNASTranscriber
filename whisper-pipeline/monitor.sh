#!/bin/bash

# Source logger
source /app/logger.sh

# Load configuration
VIDEOS_DIR=$(jq -r '.paths.videos' /app/config.json)
SCAN_INTERVAL=${SCAN_INTERVAL:-60}
PROCESSED_LIST="/app/data/logs/processed_videos.txt"

# Create processed list file if it doesn't exist
touch "$PROCESSED_LIST"

log_info "Starting video monitoring service. Checking for new videos every $SCAN_INTERVAL seconds."

# Function to get video file extensions from config
get_video_extensions() {
    extensions=$(jq -r '.file_extensions.video | join("|")' /app/config.json)
    echo "($extensions)"
}

# Main monitoring loop
while true; do
    VIDEO_EXTENSIONS=$(get_video_extensions)
    
    # Find all video files
    find "$VIDEOS_DIR" -type f -regextype posix-extended -regex ".*\.${VIDEO_EXTENSIONS}$" | while read video_file; do
        # Check if the file is already processed
        if ! grep -q "^$video_file$" "$PROCESSED_LIST"; then
            log_info "New video found: $video_file"
            
            # Process the video
            /app/process_video.sh "$video_file"
            
            # Add to processed list
            echo "$video_file" >> "$PROCESSED_LIST"
        fi
    done
    
    # Wait before next scan
    sleep $SCAN_INTERVAL
done
