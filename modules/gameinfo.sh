#!/bin/bash

echo "Configuring gameinfo.gi..."

GAMEINFO="/home/cs2server/serverfiles/game/csgo/gameinfo.gi"

# Check if already configured
if grep -q "csgo/addons/metamod" "$GAMEINFO"; then
    echo "Metamod already configured in gameinfo.gi"
    return
fi

# Insert right after Game_LowViolence csgo_lv line with proper indentation
sed -i '/^[[:space:]]*Game_LowViolence[[:space:]]\+csgo_lv/a\ \ \ \ Game csgo/addons/metamod' "$GAMEINFO"

echo "Metamod entry added to gameinfo.gi"