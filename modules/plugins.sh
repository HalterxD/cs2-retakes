#!/bin/bash

# Check for required dependencies
if ! command -v jq &> /dev/null; then
    echo "Error: jq is required but not installed. Please install jq to continue."
    return 1
fi

if ! command -v wget &> /dev/null; then
    echo "Error: wget is required but not installed."
    return 1
fi

if ! command -v unzip &> /dev/null; then
    echo "Error: unzip is required but not installed."
    return 1
fi

echo "Installing plugins from plugins.json..."

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

PLUGINS_JSON="$ROOT_DIR/plugins.json"
SERVER_DIR="/home/cs2server/serverfiles/game/csgo"

if [ ! -f "$PLUGINS_JSON" ]; then
    echo "plugins.json not found. Skipping plugin installation."
    return
fi

for plugin in $(jq -r 'keys[]' "$PLUGINS_JSON"); do

    ENABLED=$(jq -r ".\"$plugin\".enabled" "$PLUGINS_JSON")

    if [ "$ENABLED" != "true" ]; then
        echo "Skipping $plugin (disabled)"
        continue
    fi

    URL=$(jq -r ".\"$plugin\".url" "$PLUGINS_JSON")

    echo ""
    echo "Installing $plugin"

    TMP_DIR="/tmp/plugin-$plugin"
    rm -rf "$TMP_DIR"
    mkdir -p "$TMP_DIR"
    cd "$TMP_DIR" || exit

    echo "Downloading..."
    wget -q "$URL" -O plugin.zip

    echo "Extracting..."
    unzip -q plugin.zip
    
    # Clean up zip file to avoid copying it
    rm -f plugin.zip

    ########################################
    # copyPaths support
    ########################################
    jq -c ".\"$plugin\".copyPaths[]?" "$PLUGINS_JSON" | while read -r path; do
        FROM=$(echo "$path" | jq -r '.from')
        TO=$(echo "$path" | jq -r '.to')
        SRC_PATH="$TMP_DIR/$FROM"
        DEST_PATH="$SERVER_DIR/$TO"
        if [ -d "$SRC_PATH" ]; then
            echo "Copying from $FROM to $TO..."
            mkdir -p "$DEST_PATH"
            cp -r "$SRC_PATH/"* "$DEST_PATH/"
        else
            echo "Warning: copyPaths source $FROM not found in extracted archive!"
        fi
    done

    cd /tmp
    rm -rf "$TMP_DIR"

done

chown -R cs2server:cs2server /home/cs2server/serverfiles

echo ""
echo "Plugin installation complete."

PLUGIN_DIR="$SERVER_DIR/addons/counterstrikesharp/plugins"
if [ -d "$PLUGIN_DIR" ]; then
    echo ""
    echo "Installed CounterStrikeSharp plugins:"
    ls "$PLUGIN_DIR"
fi