#!/bin/sh

sudo apt update
sudo apt upgrade
sudo apt install -y --no-install-recommends \
        unclutter-fixes \
        xserver-xorg \
        xinit \
        mpv \
        fastfetch \
        socat \
        openssh-server
#        openbox \
#        wezterm \

cat <<EOF > ~/.xinitrc
#!/bin/sh

# xset -dpms
# xset s off
# xset s noblank

unclutter -idle 1 &

# wezterm --config-file ~/.config/wezterm.lua start -- fastfetch &
exec <my-server>
EOF

cat <<EOF > ~/.xinitrc
#!/bin/sh

xset -dpms
xset s off
xset s noblank

unclutter -idle 1 &

openbox &
wezterm --config-file ~/.config/wezterm.lua start -- fastfetch &
exec <my-server>
EOF


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

NET_FILE="/etc/network/interfaces"
cat <<EOF >> "$NET_FILE"

# Virtual Static IP (Fallback/Secondary)
auto eth0:0
iface eth0:0 inet static
address 192.168.1.200
netmask 255.255.255.0
EOF

chmod +x ~/.xinitrc



