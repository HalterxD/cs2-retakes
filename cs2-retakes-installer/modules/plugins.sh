#!/bin/bash

echo "Installing selected plugins..."

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

PLUGINS_JSON="$ROOT_DIR/plugins.json"

if [ ! -f "$PLUGINS_JSON" ]; then
    echo "plugins.json not found. Skipping plugin installation."
    return
fi

SERVER_DIR="/home/cs2server/serverfiles/game/csgo"
ADDONS_DIR="$SERVER_DIR/addons"
PLUGIN_DIR="$ADDONS_DIR/counterstrikesharp/plugins"

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

    ########################################
    # Detect plugin structure automatically
    ########################################

    if [ -d "addons" ]; then

        echo "Detected addons structure"
        cp -r addons/* "$ADDONS_DIR/"

    elif find . -type d -name "counterstrikesharp" | grep -q .; then

        echo "Detected counterstrikesharp structure"

        SRC=$(find . -type d -name "counterstrikesharp" | head -n1)
        cp -r "$SRC"/* "$ADDONS_DIR/counterstrikesharp/"

    elif find . -type d -name "plugins" | grep -q .; then

        echo "Detected plugins directory"

        SRC=$(find . -type d -name "plugins" | head -n1)
        cp -r "$SRC"/* "$PLUGIN_DIR/"

    else

        echo "Attempting fallback install"

        mkdir -p "$PLUGIN_DIR/$plugin"
        cp -r ./* "$PLUGIN_DIR/$plugin/" 2>/dev/null || true

    fi

    cd /tmp
    rm -rf "$TMP_DIR"

done

chown -R cs2server:cs2server /home/cs2server/serverfiles

echo "Plugin installation finished."