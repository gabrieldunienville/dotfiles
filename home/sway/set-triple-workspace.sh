#!/bin/bash

swaymsg "workspace 1; move workspace to output HDMI-A-1"
swaymsg "workspace 2; move workspace to output HDMI-A-1"
swaymsg "workspace 3; move workspace to output HDMI-A-1"
swaymsg "workspace 4; move workspace to output HDMI-A-1"
swaymsg "workspace 5; move workspace to output HDMI-A-1"
swaymsg "workspace 6; move workspace to output HDMI-A-1"
swaymsg "workspace 7; move workspace to output DP-3"
swaymsg "workspace 8; move workspace to output HDMI-A-1"
swaymsg "workspace 9; move workspace to output HDMI-A-1"
swaymsg "workspace 10; move workspace to output eDP-1"


# swaymsg "output HDMI-A-1 position 0,0"
# swaymsg "output eDP-1 position -1080,1000"
# swaymsg "output DP-3 position 1000,3840"

# Laptop (eDP-1) on the left
swaymsg "output eDP-1 pos -1920 0"

# Main 4K (HDMI-A-1) in center
swaymsg "output HDMI-A-1 pos 0 0"

# ViewSonic (DP-3) centered below main
swaymsg "output DP-3 pos 960 2160"    # (3840 - 1920) / 2 = 960 to center it
