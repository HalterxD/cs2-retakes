#!/bin/bash

echo "Installing selected plugins..."

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

PLUGINS_JSON="$ROOT_DIR/plugins.json"

if [ ! -f "$PLUGINS_JSON" ]; then
    echo "plugins.json not found. Skipping plugin installation."
    return
fi

PLUGIN_DIR="/home/cs2server/serverfiles/game/csgo/addons/counterstrikesharp/plugins"

mkdir -p "$PLUGIN_DIR"

for plugin in $(jq -r 'keys[]' "$PLUGINS_JSON"); do

    URL=$(jq -r ".\"$plugin\".url" "$PLUGINS_JSON")

    if [ "$URL" = "null" ] || [ -z "$URL" ]; then
        echo "Skipping $plugin (no URL)"
        continue
    fi

    if [ -d "$PLUGIN_DIR/$plugin" ]; then
        echo "$plugin already installed. Skipping."
        continue
    fi

    VERSION=$(basename "$URL" | sed 's/.zip//')

    echo "Installing $plugin ($VERSION)..."

    TMP_DIR="/tmp/plugin-$plugin"
    rm -rf "$TMP_DIR"
    mkdir -p "$TMP_DIR"

    cd "$TMP_DIR" || exit

    wget -q "$URL" -O plugin.zip

    unzip -q plugin.zip

    if [ -d "addons" ]; then
        cp -r addons/* /home/cs2server/serverfiles/game/csgo/addons/
    
    elif [ -d "counterstrikesharp" ]; then
        mkdir -p /home/cs2server/serverfiles/game/csgo/addons/counterstrikesharp
        cp -r counterstrikesharp/* /home/cs2server/serverfiles/game/csgo/addons/counterstrikesharp/
    
    else
        echo "Unknown archive structure for $plugin"
    fi

    rm -rf "$TMP_DIR"

done

chown -R cs2server:cs2server /home/cs2server/serverfiles

echo "Plugin installation finished."