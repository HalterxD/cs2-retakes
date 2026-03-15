#!/bin/bash

echo "==== CS2 Retakes Server Installer ===="

read -p "Steam GSLT Token: " GSLT
read -p "Server Name: " SERVER_NAME
read -p "Server Tags (comma separated): " SERVER_TAGS
read -p "Server Owner SteamID: " OWNER_STEAMID
read -p "Admin SteamIDs (comma separated): " ADMINS
read -p "Discord Webhook URL (optional): " WEBHOOK

echo ""
echo "Select plugins to install:"

declare -A PLUGINS

PLUGINS[retakes]=0
PLUGINS[allocator]=0
PLUGINS[instaplant]=0
PLUGINS[instadefuse]=0
PLUGINS[rtv]=0
PLUGINS[clutchannounce]=0
PLUGINS[simpleadmin]=0

for plugin in "${!PLUGINS[@]}"; do
  read -p "Install $plugin? (y/n): " answer
  if [[ $answer == "y" ]]; then
    PLUGINS[$plugin]=1
  fi
done

export GSLT SERVER_NAME SERVER_TAGS OWNER_STEAMID ADMINS WEBHOOK
export SELECTED_PLUGINS=$(printf "%s\n" "${!PLUGINS[@]}" | while read p; do [ "${PLUGINS[$p]}" -eq 1 ] && echo "$p"; done | paste -sd "," -)