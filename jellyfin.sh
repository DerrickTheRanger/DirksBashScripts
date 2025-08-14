#!/bin/bash
HOME_DIR="$HOME"
docker run -d \
 --name jellyfin \
 --user 1000:1000 \
 --net=host \
 --volume "$HOME_DIR/jellyfin/config":/config \
 --volume "$HOME_DIR/jellyfin/cache":/cache \
 --mount type=bind,source="HOME_DIR/jellyfin/media",target=/media \
 --restart=unless-stopped \
jellyfin/jellyfin
