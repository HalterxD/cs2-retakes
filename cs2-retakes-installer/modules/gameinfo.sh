echo "Checking gameinfo.gi..."

GAMEINFO="/home/cs2server/serverfiles/game/csgo/gameinfo.gi"

if grep -q "addons/metamod" "$GAMEINFO"; then
    echo "Metamod path already present."
else
    echo "Patching gameinfo.gi..."

    sed -i '/SearchPaths/a\ \ \ \ Game\tcsgo/addons/metamod' "$GAMEINFO"
fi