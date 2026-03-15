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
PLUGIN_DIR="$SERVER_DIR/addons/counterstrikesharp/plugins"

mkdir -p "$PLUGIN_DIR"

for plugin in $(jq -r 'keys[]' "$PLUGINS_JSON"); do

    URL=$(jq -r ".\"$plugin\".url" "$PLUGINS_JSON")

    if [ "$URL" = "null" ] || [ -z "$URL" ]; then
        echo "Skipping $plugin (no URL)"
        continue
    fi

    echo "Installing $plugin..."

    TMP_DIR="/tmp/plugin-$plugin"
    rm -rf "$TMP_DIR"
    mkdir -p "$TMP_DIR"

    cd "$TMP_DIR" || exit

    wget -q "$URL" -O plugin.zip
    unzip -q plugin.zip

    ########################################
    # Detect plugin folders by DLL
    ########################################

    for dll in $(find . -name "*.dll"); do

        PLUGIN_FOLDER=$(dirname "$dll")
        NAME=$(basename "$PLUGIN_FOLDER")

        echo "Installing plugin folder: $NAME"

        rm -rf "$PLUGIN_DIR/$NAME"
        mkdir -p "$PLUGIN_DIR/$NAME"

        cp -r "$PLUGIN_FOLDER"/* "$PLUGIN_DIR/$NAME/"

    done

    cd /tmp
    rm -rf "$TMP_DIR"

done

chown -R cs2server:cs2server /home/cs2server/serverfiles

echo ""
echo "Installed plugins:"
ls "$PLUGIN_DIR"