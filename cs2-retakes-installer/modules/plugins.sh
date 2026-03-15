#!/bin/bash

echo "Installing selected plugins..."

IFS=',' read -ra LIST <<< "$SELECTED_PLUGINS"

for plugin in "${LIST[@]}"; do

  echo "Installing $plugin"

  REPO=$(jq -r ".\"$plugin\".repo" plugins.json)

  API="https://api.github.com/repos/$(echo $REPO | sed 's|https://github.com/||')/releases/latest"

  URL=$(curl -s $API | jq -r '.assets[0].browser_download_url')

  cd /tmp

  wget -O plugin.zip $URL

  unzip -o plugin.zip

  cp -r addons /home/cs2server/serverfiles/game/csgo/ || true

  rm -rf plugin.zip addons

done

chown -R cs2server:cs2server /home/cs2server/serverfiles