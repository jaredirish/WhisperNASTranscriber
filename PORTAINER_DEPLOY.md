# Deploying to Portainer on Synology NAS

## Quick Deploy Steps

1. **In Portainer:**
   - Go to "Stacks" → "Add stack"
   - Name: `whisper-pipeline`
   - Build method: **Repository**
   - Repository URL: `https://github.com/[YOUR-USERNAME]/[YOUR-REPO-NAME]`
   - Repository reference: `main`
   - Compose file path: `docker-compose.yml`

2. **Before deploying, create these directories on your NAS:**
   ```
   mkdir -p /volume1/docker/whisper-pipeline/data/{videos,audio,transcripts,models,logs}
   ```

3. **Update the volume paths in Portainer stack editor if needed:**
   - Change `./data/` to your actual NAS path, e.g., `/volume1/docker/whisper-pipeline/data/`

## Troubleshooting

If deployment fails:

1. **Check Portainer logs** for specific error messages
2. **Verify directory permissions** - Docker needs read/write access
3. **Ensure sufficient resources** - The container needs ~2GB RAM
4. **Check for port conflicts** - Make sure no other containers use the same ports

## Usage After Deployment

1. Place video files in: `/volume1/docker/whisper-pipeline/data/videos/`
2. Check transcripts in: `/volume1/docker/whisper-pipeline/data/transcripts/`
3. Monitor logs in: `/volume1/docker/whisper-pipeline/data/logs/`

The container will automatically start processing videos within 2 minutes of being placed in the videos directory.