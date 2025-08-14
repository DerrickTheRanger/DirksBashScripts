#!/bin/bash
echo "Starting DirkScript"
echo "Updating Ubuntu..."
sudo apt update && apt upgrade -y
echo "Update done!"
echo "Installing jellyfin via docker..."
sudo docker pull jellyfin/jellyfin
echo "jellyfin install complete!"
echo "Creating Jellyfin filesystem..."
mkdir jellyfin
mkdir jellyfin/config
mkdir jellyfin/cache
mkdir jellyfin/media
mkdir jellyfin/media/videos
echo "Filesystem created!"
echo "Starting docker container..."
curl https://raw.githubusercontent.com/DerrickTheRanger/DirksBashScripts/refs/heads/main/jellyfin.sh | bash
