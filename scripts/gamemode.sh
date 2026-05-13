#!/usr/bin/env sh

# 1. Path to a temporary flag file to track our toggle state
FLAG="/tmp/gamemode_active"

# 2. Tell Noctalia to flip the hardware performance switch
noctalia-shell ipc call powerProfile toggleNoctaliaPerformance

# 3. Handle the Tiling Aesthetics (Gaps/Blur/Rounding)
if [ ! -f "$FLAG" ]; then
    # Entering Game Mode
    touch "$FLAG"
    noctalia-shell ipc call powerProfile enableNoctaliaPerformance
    wm-ctrl gaps_off
else
    # Leaving Game Mode
    rm "$FLAG"
    noctalia-shell ipc call powerProfile disableNoctaliaPerformance
    wm-ctrl reload
fi
