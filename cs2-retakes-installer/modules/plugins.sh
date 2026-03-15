# #!/bin/bash

# echo "Installing selected plugins..."

# IFS=',' read -ra LIST <<< "$SELECTED_PLUGINS"

# for plugin in "${LIST[@]}"; do

#   echo "Installing $plugin"

#   REPO=$(jq -r ".\"$plugin\".repo" plugins.json)

#   API="https://api.github.com/repos/$(echo $REPO | sed 's|https://github.com/||')/releases/latest"

#   URL=$(curl -s $API | jq -r '.assets[0].browser_download_url')

#   cd /tmp

#   wget -O plugin.zip $URL

#   unzip -o plugin.zip

#   cp -r addons /home/cs2server/serverfiles/game/csgo/ || true

#   rm -rf plugin.zip addons

# done

# chown -R cs2server:cs2server /home/cs2server/serverfiles


echo "Installing selected plugins..."

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

PLUGINS_JSON="$ROOT_DIR/plugins.json"

if [ ! -f "$PLUGINS_JSON" ]; then
    echo "plugins.json not found. Skipping plugin installation."
    exit 0
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

    echo "Installing $plugin..."

    cd /tmp
    wget -q "$URL" -O plugin.zip

    unzip -o plugin.zip

    cp -r addons/* /home/cs2server/serverfiles/game/csgo/addons/

done

chown -R cs2server:cs2server /home/cs2server/serverfiles