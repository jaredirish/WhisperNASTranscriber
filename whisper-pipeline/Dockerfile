FROM debian:bullseye-slim

# Install dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    git \
    ffmpeg \
    wget \
    inotify-tools \
    python3 \
    python3-pip \
    jq \
    && rm -rf /var/lib/apt/lists/*

# Set up working directory
WORKDIR /app

# Clone and build whisper.cpp
RUN git clone https://github.com/ggml-org/whisper.cpp.git && \
    cd whisper.cpp && \
    make

# Create directories
RUN mkdir -p /app/data/videos \
    /app/data/audio \
    /app/data/transcripts \
    /app/data/models \
    /app/data/logs

# Copy scripts
COPY entrypoint.sh download_model.sh process_video.sh monitor.sh convert_audio.sh transcribe.sh logger.sh config.json /app/
RUN chmod +x /app/*.sh

# Set entrypoint
ENTRYPOINT ["/app/entrypoint.sh"]
