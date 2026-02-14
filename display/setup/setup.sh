#!/usr/bin/env bash

# sudo apt update
# sudo apt upgrade
# sudo apt install -y --no-install-recommends \
#         unclutter-fixes \
#         xserver-xorg \
#         xinit \
#         mpv \
#         fastfetch \
#         socat \
#         openssh-server
#        openbox \
#        wezterm \

# cat <<EOF > ~/.xinitrc
# #!/bin/sh
#
# # xset -dpms
# # xset s off
# # xset s noblank
#
# unclutter -idle 1 &
#
# # wezterm --config-file ~/.config/wezterm.lua start -- fastfetch &
# exec <my-server>
# EOF
#
# cat <<EOF > ~/.xinitrc
# #!/bin/sh
#
# xset -dpms
# xset s off
# xset s noblank
#
# unclutter -idle 1 &
#
# openbox &
# wezterm --config-file ~/.config/wezterm.lua start -- fastfetch &
# exec <my-server>
# EOF

# chmod +x ~/.xinitrc

# cat <<EOF > ~/.config/wezterm.lua
# -- Pull in the wezterm API
# local wezterm = require 'wezterm'
#
# -- This will hold the configuration.
# local config = wezterm.config_builder()
#
# config.enable_tab_bar = false
#
# local mux = wezterm.mux
#
# wezterm.on('gui-startup', function(cmd)
#   local tab, pane, window = mux.spawn_window(cmd or {})
#   window:gui_window():maximize()
# end)
#
# -- Finally, return the configuration to wezterm:
# return config
# EOF

# Sudo permissions at start
sudo echo

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
sudo systemctl restart systemd-networkd

# Setup Auto login
mkdir -p /etc/systemd/system/getty@tty1.service.d
sudo tee -a /etc/systemd/system/getty@tty1.service.d/autologin.conf > /dev/null <<EOF
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin $USER --noclear %I $TERM
EOF

systemctl daemon-reexec
systemctl daemon-reload


# Copy SSH keys
mkdir -p ~/.ssh
cat <<EOF >> "$HOME/.ssh/authorized_keys"
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFi3bU1NHLQU56N08qbxIJAS8/gVJAzt/vr8Q20Zmx63 bluerachapradit@SOE-MAC-AW6Q6LR
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAc0jA2C50dJ9zZbyjXVmlD0x5TvnblKVm1PxRqnPFJ8 markome@nixos
EOF
