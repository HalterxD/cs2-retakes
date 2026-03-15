#!/bin/bash

ADMIN_FILE="/home/cs2server/serverfiles/game/csgo/addons/counterstrikesharp/configs/admins.json"

mkdir -p $(dirname $ADMIN_FILE)

echo "Creating admin config..."

cat <<EOF > $ADMIN_FILE
{
  "Admins": [
    {
      "SteamID": "$OWNER_STEAMID",
      "Flags": "z"
    }
  ]
}
EOF

IFS=',' read -ra ADMINLIST <<< "$ADMINS"

for id in "${ADMINLIST[@]}"; do
cat <<EOF >> $ADMIN_FILE
,
{
  "SteamID": "$id",
  "Flags": "z"
}
EOF
done