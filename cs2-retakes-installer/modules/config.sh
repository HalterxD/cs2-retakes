#!/bin/bash

echo "Configuring server files..."

CFG_DIR="/home/cs2server/serverfiles/game/csgo/cfg"
SERVER_CFG="$CFG_DIR/server.cfg"
MAPCYCLE="/home/cs2server/serverfiles/game/csgo/mapcycle.txt"

mkdir -p "$CFG_DIR"

########################################
# server.cfg
########################################

declare -a SERVER_SETTINGS=(
'hostname "{{SERVER_NAME}}"'
'sv_tags "{{SERVER_TAGS}}"'
'mp_autoteambalance 0'
'mp_limitteams 0'
'sv_cheats 0'
'sv_lan 0'
'maxplayers 10'
)

if [ ! -f "$SERVER_CFG" ]; then

    echo "Creating server.cfg"

    for line in "${SERVER_SETTINGS[@]}"; do
        echo "$line" >> "$SERVER_CFG"
    done

else

    echo "Merging server.cfg settings"

    for line in "${SERVER_SETTINGS[@]}"; do

        KEY=$(echo "$line" | awk '{print $1}')

        if ! grep -q "^$KEY" "$SERVER_CFG"; then
            echo "Adding missing setting: $KEY"
            echo "$line" >> "$SERVER_CFG"
        fi

    done

fi


########################################
# Replace template values
########################################

sed -i "s/{{SERVER_NAME}}/$SERVER_NAME/g" "$SERVER_CFG"
sed -i "s/{{SERVER_TAGS}}/$SERVER_TAGS/g" "$SERVER_CFG"


########################################
# mapcycle.txt
########################################

if [ ! -f "$MAPCYCLE" ]; then

    echo "Creating mapcycle.txt"

cat <<EOF > "$MAPCYCLE"
de_mirage
de_dust2
de_inferno
de_nuke
de_ancient
de_anubis
de_overpass
de_vertigo
EOF

else
    echo "mapcycle.txt already exists. Skipping."
fi


########################################
# Permissions
########################################

chown cs2server:cs2server "$SERVER_CFG" "$MAPCYCLE"

echo "Server configuration complete."