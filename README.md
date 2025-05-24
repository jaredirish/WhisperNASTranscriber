# Whisper.cpp Docker Pipeline for Synology NAS

This project sets up an automated pipeline for converting videos to audio and then transcribing them using whisper.cpp on a Synology NAS using Docker and Portainer.

## Features

- Deploy whisper.cpp Docker container using Portainer
- Automatically converts video files to audio using FFmpeg
- Processes audio files with whisper.cpp to generate text transcriptions
- Monitors the process and provides status updates
- Organizes files in a structured way (videos, audio, transcriptions)
- Supports multiple video formats (mp4, mkv, avi, mov, etc.)
- Generates transcripts in multiple formats (txt, vtt, srt, json with timestamps)
- Configurable model size (tiny, base, small, medium, large)

## Prerequisites

- Synology NAS with Docker support
- Portainer installed on your Synology NAS
- Sufficient storage space for videos, audio files, and models

## Installation Instructions

### 1. Set Up Directories on Your Synology NAS

Create the following directory structure on your NAS:
```
whisper-pipeline/
├── data/
│   ├── videos/      # Place your videos here for processing
│   ├── audio/       # Extracted audio will be stored here
│   ├── transcripts/ # Generated transcripts will be stored here
│   ├── models/      # Downloaded Whisper models will be stored here
│   └── logs/        # Log files will be stored here
├── whisper-pipeline/ # Contains all the scripts and Dockerfile
└── docker-compose.yml
```

### 2. Download and Deploy Using Portainer

1. Access your Portainer installation (typically at http://your-nas-ip:9000)
2. Go to "Stacks" in the left sidebar and click "Add stack"
3. Give your stack a name (e.g., "whisper-pipeline")
4. Upload the docker-compose.yml file or paste its contents in the editor
5. Click "Deploy the stack"

### 3. Configuration Options

Edit the `docker-compose.yml` file to adjust the following parameters:

- `MODEL_SIZE`: Choose from tiny, base, small, medium, or large (default: base)
  - tiny: fastest, least accurate (75MB)
  - base: good balance of speed and accuracy (142MB)
  - small: better accuracy, slower (466MB)
  - medium: even better accuracy, even slower (1.5GB)
  - large: best accuracy, slowest (3GB)
- `LANGUAGE`: Specify a language code to improve accuracy (e.g., "en" for English)
- `THREADS`: Number of CPU threads to use (adjust based on your NAS capabilities)
- `SCAN_INTERVAL`: How often to check for new videos (in seconds)

## Directory Structure

The project uses the following directory structure:

```
whisper-pipeline/
├── data/
│   ├── videos/      # Place your videos here for processing
│   ├── audio/       # Extracted audio will be stored here
│   ├── transcripts/ # Generated transcripts will be stored here
│   ├── models/      # Downloaded Whisper models will be stored here
│   └── logs/        # Log files will be stored here
├── whisper-pipeline/ 
    ├── Dockerfile          # Container build instructions
    ├── config.json         # Configuration settings
    ├── entrypoint.sh       # Main entry script
    ├── download_model.sh   # Downloads the whisper model
    ├── monitor.sh          # Monitors video directory for new files
    ├── process_video.sh    # Processes each video file
    ├── convert_audio.sh    # Converts video to audio
    ├── transcribe.sh       # Transcribes audio to text
    └── logger.sh           # Logging functions
```

## Usage

1. After deploying the stack, the container will automatically start monitoring the `data/videos` directory.
2. Simply copy or move your video files into this directory.
3. The system will:
   - Automatically detect new video files
   - Convert them to audio (MP3 format)
   - Transcribe the audio to text using whisper.cpp
   - Generate transcription files in multiple formats (TXT, VTT, SRT, JSON)
4. All transcription files will be available in the `data/transcripts` directory.

## Monitoring and Logs

- Check the logs in the `data/logs` directory for details about the processing:
  - `whisper-pipeline.log`: General processing logs
  - `error.log`: Error messages
  - `processed_videos.txt`: List of processed video files

## Supported File Formats

### Video Formats
- MP4 (.mp4)
- MKV (.mkv)
- AVI (.avi)
- MOV (.mov)
- WMV (.wmv)
- FLV (.flv)
- WebM (.webm)

### Output Transcript Formats
- Plain text (.txt)
- WebVTT subtitles (.vtt)
- SRT subtitles (.srt)
- JSON with timestamps (.json)

## Troubleshooting

### Common Issues

1. **Model Download Fails**
   - Check your NAS internet connection
   - Try using a smaller model size
   - Manually download the model file and place it in the `data/models` directory

2. **Video Processing Fails**
   - Check the error logs at `data/logs/error.log`
   - Ensure the video format is supported
   - Try with a different video file to rule out corruption

3. **Container Not Starting**
   - Check Portainer logs for the container
   - Ensure you have sufficient permissions for the directories
   - Make sure Docker has enough resources allocated

## Performance Considerations

- The transcription speed depends on your NAS CPU capabilities.
- For faster processing on lower-end NAS devices, use the "tiny" or "base" model.
- The "medium" and "large" models provide better accuracy but require more processing power.
- Adjust the `THREADS` parameter to match your NAS CPU core count for optimal performance.

## Customization

You can customize the pipeline by modifying the scripts in the `whisper-pipeline` directory:

- Edit `config.json` to add additional supported file formats
- Modify `transcribe.sh` to change transcription parameters
- Adjust `monitor.sh` to change the monitoring behavior

