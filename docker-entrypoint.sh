#!/bin/bash
set -e

# Sync precompiled assets from image to volume
# This ensures the volume always has the latest assets after rebuild
if [ -d /app/public/assets-image ]; then
  echo "Syncing assets from image to volume..."

  # Remove old files including hidden files (e.g., .sprockets-manifest-*.json)
  find /app/public/assets -mindepth 1 -maxdepth 1 -exec rm -rf -- {} +

  # Copy all files including hidden files
  cp -a /app/public/assets-image/. /app/public/assets/

  echo "Assets sync completed."
fi

# Execute the main command
exec "$@"
