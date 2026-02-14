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

sudo echo

echo -n "Enter a number (10-255): " 
read num

# Check if it's an integer
if ! [[ "$num" =~ ^[0-9]+$ ]]; then
  echo "Error: Not a valid number." >&2
  exit 1
fi

# Check range
if (( num < 10 || num > 255 )); then
  echo "Error: Number must be between 10 and 255." >&2
  exit 1
fi

NET_FILE="/etc/network/interfaces"
sudo tee -a "$NET_FILE" > /dev/null <<EOF

# Virtual Static IP (Fallback/Secondary)
auto eth0:0
iface eth0:0 inet static
address 192.168.1.$num
netmask 255.255.255.0
EOF

mkdir -p ~/.ssh
cat <<EOF >> "$HOME/.ssh/authorized_keys"
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFi3bU1NHLQU56N08qbxIJAS8/gVJAzt/vr8Q20Zmx63 bluerachapradit@SOE-MAC-AW6Q6LR
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAc0jA2C50dJ9zZbyjXVmlD0x5TvnblKVm1PxRqnPFJ8 markome@nixos
EOF
