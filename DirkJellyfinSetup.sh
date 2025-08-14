#!/bin/bash
set -e  # Exit on any error
echo "Starting DirkScript"
echo "Updating Ubuntu..."
sudo apt update && sudo apt upgrade -y
echo "Update done!"
if ! command -v docker &>/dev/null; then
    echo "Installing Docker..."
    sudo apt install -y docker.io
    sudo systemctl enable --now docker
fi
if ! command -v smbpasswd &>/dev/null; then
    echo "Installing Samba..."
    sudo apt install -y samba
fi
echo "Installing jellyfin via docker..."
sudo docker pull jellyfin/jellyfin
echo "jellyfin install complete!"
HOME_DIR="$HOME"
MEDIA_DIR="$HOME/jellyfin/media"
echo "Creating Jellyfin filesystem in $HOME_DIR..."
mkdir -p "$HOME_DIR/jellyfin/config" \
         "$HOME_DIR/jellyfin/cache" \
         "$MEDIA_DIR/videos"
echo "Filesystem created!"

# Setup Samba share for media
SHARE_NAME="media"
SAMBA_USER="$USER"


# Backup Samba config (only once)
if [ ! -f /etc/samba/smb.conf.bak ]; then
    sudo cp /etc/samba/smb.conf /etc/samba/smb.conf.bak
fi

# Append share definition if not already present
if ! grep -q "^\[$SHARE_NAME\]" /etc/samba/smb.conf; then
    echo "Adding Samba share for $MEDIA_DIR..."
    sudo bash -c "cat >> /etc/samba/smb.conf <<EOL

[$SHARE_NAME]
   path = $MEDIA_DIR
   browseable = yes
   read only = no
   guest ok = no
EOL"
fi

# Add Samba user (will prompt for password once)
if ! sudo pdbedit -L | grep -q "^$SAMBA_USER:"; then
    echo "Creating Samba user: $SAMBA_USER"
    sudo smbpasswd -a "$SAMBA_USER" < /dev/tty
fi

# Restart Samba
sudo systemctl restart smbd nmbd
echo "Samba share '$SHARE_NAME' available."

echo "Starting docker container..."
sudo docker run -d \
 --name jellyfin \
 --user 1000:1000 \
 --net=host \
 --volume "$HOME_DIR/jellyfin/config":/config \
 --volume "$HOME_DIR/jellyfin/cache":/cache \
 --mount type=bind,source="$HOME_DIR/jellyfin/media",target=/media \
 --restart=unless-stopped \
jellyfin/jellyfin
#curl https://raw.githubusercontent.com/DerrickTheRanger/DirksBashScripts/refs/heads/main/jellyfin.sh | bash

IP_ADDR=$(hostname -I | awk '{print $1}')
echo "All done!"
echo "Access Jellyfin in browser: http://$IP_ADDR:8096"
echo "Samba user is $SAMABA_USER"
echo "Access media folder in Windows: \\\\$IP_ADDR\\$SHARE_NAME"
