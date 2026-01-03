#!/bin/sh


sudo apt update
sudo apt install -y --no-install-recommends \
        unclutter-fixes \
        xserver-xorg \
        xinit \
        mpv \
        openbox \
        fastfetch \
        wezterm

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

cat <<EOF > ~/.config/wezterm.lua
-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()

config.enable_tab_bar = false

local mux = wezterm.mux

wezterm.on('gui-startup', function(cmd)
  local tab, pane, window = mux.spawn_window(cmd or {})
  window:gui_window():maximize()
end)

-- Finally, return the configuration to wezterm:
return config
EOF

chmod +x ~/.xinitrc

