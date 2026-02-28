#!/usr/bin/env bash

# Setup Autostart
mkdir -p ~/.config/my-mpv
sudo tee "$HOME/.config/my-mpv/my-mpv.sh" > /dev/null <<EOF
#!/usr/bin/env bash
# Disable desktop
pkill xfdesktop

# Disable compositor
xfconf-query -c xfwm4 -p /general/use_compositing -s false

# Disable thunar daemon
pkill thunar

# Optional: disable power manager (desktop only)
pkill -f xfce4-power-manager

# Set Resolution
xrandr -s 1920x1080

# Start MPV
mpv --input-ipc-server=/tmp/mpv-socket --fullscreen --no-border --idle --pause
EOF
sudo chmod +x ~/.config/my-mpv/my-mpv.sh

sudo tee "$HOME/.config/autostart/my-mpv.desktop" > /dev/null <<EOF
[Desktop Entry]
Type=Application
Name=my-mpv
Exec=/home/movie/.config/my-mpv/my-mpv.sh
Terminal=true
EOF

# Setup Audio
mkdir -p ~/.config/wireplumber/wireplumber.conf.d
sudo tee "$HOME/.config/wireplumber/wireplumber.conf.d/45-set-low-prio.conf" > /dev/null <<EOF
monitor.alsa.rules = [
  {
    matches = [
      {
        node.name = "alsa_output.platform-5096000.codec.stereo-fallback"
      }
    ], actions = {
      update-props = {
        priority.session = 500
      }
    }
  }
]
EOF

#!/bin/bash

# Configuration Variables
MASTER_IP="192.168.1.10"
NETWORK_RANGE="192.168.1.0/24"
CONFIG_FILE="/etc/chrony/chrony.conf"

# Ensure script is run with sudo
if [ "$EUID" -ne 0 ]; then 
  echo "Please run as root (use sudo)"
  exit
fi

echo "------------------------------------------"
echo " Orange Pi NTP Configuration Tool"
echo "------------------------------------------"
read -pr "Is this the MASTER Pi (192.168.1.10)? (y/n): " IS_MASTER

if [[ $IS_MASTER =~ ^[Yy]$ ]]; then
    echo "Configuring as MASTER SERVER..."
    
    # 1. Ensure it allows local queries
    if ! grep -q "allow $NETWORK_RANGE" $CONFIG_FILE; then
        echo "allow $NETWORK_RANGE" >> $CONFIG_FILE
    fi

    # 2. Enable Local Stratum (so it works offline)
    if ! grep -q "local stratum 10" $CONFIG_FILE; then
        echo "local stratum 10" >> $CONFIG_FILE
    fi
    
    # 3. Clean up accidental self-referencing lines
    sed -i "/server $MASTER_IP/d" $CONFIG_FILE
    
    echo "Master configuration complete."

else
    echo "Configuring as DEPENDENT CLIENT..."
    
    # 1. Remove existing pool/server lines to avoid confusion
    sed -i 's/^pool/#pool/' $CONFIG_FILE
    sed -i 's/^server/#server/' $CONFIG_FILE
    
    # 2. Add the Master Pi as the primary source at the top
    # Check if already added to avoid duplicates
    if ! grep -q "server $MASTER_IP" $CONFIG_FILE; then
        sed -i "1i server $MASTER_IP iburst" $CONFIG_FILE
    fi
    
    echo "Dependent configuration complete."
fi

# Restart service to apply changes
echo "Restarting Chrony..."
systemctl restart chrony
