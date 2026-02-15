#!/usr/bin/env bash

# Sudo permissions at start
sudo echo

# Update System
sudo apt update
sudo apt upgrade
armbian-upgrade

# Install Packages
sudo apt install -y --no-install-recommends \
        socat \
        openssh-server \
        mpv \
        pipewire pipewire-audio-client-libraries pipewire-pulse pipewire-alsa wireplumber \
        ffmpeg

# Read in PI number to be used in IP
read -r -p "Enter a number (10-255): " num < /dev/tty

if ! [[ "$num" =~ ^[0-9]+$ ]] || (( num < 10 || num > 255 )); then
  echo "Invalid number"
  exit 1
fi
echo "Using 192.168.1.$num"

# Set static IP
NET_FILE="/etc/systemd/network/10-end0.network"
sudo tee -a "$NET_FILE" > /dev/null <<EOF
[Match]
Name=end0

[Network]
DHCP=yes
Address=192.168.1.$num/24
Gateway=192.168.1.1
DNS=8.8.8.8
EOF
sudo systemctl enable systemd-networkd > /dev/null

# Setup Auto login
sudo tee -a /etc/lightdm/lightdm.conf > /dev/null <<EOF
[SeatDefaults]
autologin-user=$USER
autologin-user-timeout=0
EOF

# Fix Audio
systemctl --user --now disable pulseaudio.service pulseaudio.socket
systemctl --user mask pulseaudio
systemctl --user --now enable pipewire pipewire-pulse wireplumber
wpctl set-default 32

# Setup Auto Launch MPV on start up
sudo tee -a "$HOME/.config/autostart/my-mpv.desktop" > /dev/null <<EOF
[Desktop Entry]
Type=Application
Name=my-mpv
Exec=rm -f /tmp/mpv-socket && mpv --input-ipc-server=/tmp/mpv-socket --fullscreen --no-border --idle --pause 2>&1 | tee /home/$USER/mpv-log
Terminal=true
EOF

# Copy SSH keys
mkdir -p ~/.ssh
cat <<EOF >> "$HOME/.ssh/authorized_keys"
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFi3bU1NHLQU56N08qbxIJAS8/gVJAzt/vr8Q20Zmx63 bluerachapradit@SOE-MAC-AW6Q6LR
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAc0jA2C50dJ9zZbyjXVmlD0x5TvnblKVm1PxRqnPFJ8 markome@nixos
EOF

sudo reboot
