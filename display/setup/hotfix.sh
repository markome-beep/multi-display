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
chmod +x ~/.config/my-mpv/my-mpv.sh

sudo tee "$HOME/.config/autostart/my-mpv.desktop" > /dev/null <<EOF
[Desktop Entry]
Type=Application
Name=my-mpv
Exec=/home/movie/.config/my-mpv/my-mpv.sh
Terminal=true
EOF

# Setup Audio
mkdir -p ~/.config/wireplumber/wireplumber.conf.d
sudo tee "$HOME/.config/autostart/my-mpv.desktop" > /dev/null <<EOF
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
