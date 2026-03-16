#!/bin/bash

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

    NAME=$(jq -r ".\"$plugin\".name" "$PLUGINS_JSON")
    URL=$(jq -r ".\"$plugin\".url" "$PLUGINS_JSON")
    EXTRACT_PATH=$(jq -r ".\"$plugin\".extractPath" "$PLUGINS_JSON")
    INSTALL_PATH=$(jq -r ".\"$plugin\".installPath" "$PLUGINS_JSON")
    VERSION=$(jq -r ".\"$plugin\".version" "$PLUGINS_JSON")

    echo ""
    echo "Installing $NAME ($VERSION)"

    TMP_DIR="/tmp/plugin-$plugin"
    rm -rf "$TMP_DIR"
    mkdir -p "$TMP_DIR"
    cd "$TMP_DIR" || exit

    echo "Downloading..."
    wget -q "$URL" -O plugin.zip

    echo "Extracting..."
    unzip -q plugin.zip

    SRC="$TMP_DIR/$EXTRACT_PATH"
    DEST="$SERVER_DIR/$INSTALL_PATH"

    if [ ! -d "$SRC" ]; then
        echo "Extraction path $EXTRACT_PATH not found for $plugin"
        continue
    fi

    mkdir -p "$DEST"

    ########################################
    # Copy plugin DLLs
    ########################################
    echo "Copying plugin DLLs..."
    for dll in $(find "$SRC" -name "*.dll"); do
        PLUGIN_NAME=$(basename "$dll" .dll)
        PLUGIN_DEST="$DEST/$PLUGIN_NAME"
        mkdir -p "$PLUGIN_DEST"
        cp "$dll" "$PLUGIN_DEST/"
        # copy pdb if exists
        if [ -f "${dll%.dll}.pdb" ]; then
            cp "${dll%.dll}.pdb" "$PLUGIN_DEST/"
        fi
        echo "Installed plugin: $PLUGIN_NAME"
    done

    ########################################
    # copyPaths support
    ########################################
    jq -c ".\"$plugin\".copyPaths[]?" "$PLUGINS_JSON" | while read -r path; do
        FROM=$(echo "$path" | jq -r '.from')
        TO=$(echo "$path" | jq -r '.to')
        SRC_PATH="$SRC/$FROM"
        DEST_PATH="$SERVER_DIR/$TO"
        if [ -d "$SRC_PATH" ]; then
            echo "Copying from $SRC_PATH to $DEST_PATH..."
            mkdir -p "$DEST_PATH"
            cp -r "$SRC_PATH/"* "$DEST_PATH/"
        else
            echo "Warning: copyPaths source $SRC_PATH does not exist!"
        fi
    done

    ########################################
    # Post install commands
    ########################################
    echo "Running post-install commands..."
    jq -r ".\"$plugin\".postInstall[]?" "$PLUGINS_JSON" | while read -r cmd; do
        eval "$cmd"
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