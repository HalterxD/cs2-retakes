#!/bin/bash

set -euo pipefail

# Always run from installer directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

LOG="logs/installer.log"
mkdir -p logs

exec > >(tee -a "$LOG")
exec 2>&1

echo "==== CS2 Server Manager Installer ===="

source cli.sh

########################################
# Detect existing installation
########################################

if id "cs2server" &>/dev/null; then
  echo "Existing install detected"
  read -rp "Repair existing install? (y/n): " repair
fi

if [ -d "/home/cs2server/serverfiles" ]; then
    echo "Existing CS2 installation detected."
    read -rp "Repair installation? (y/n): " repair

    if [[ "${repair:-n}" != "y" ]]; then
        echo "Aborting install."
        exit 1
    fi
fi

########################################
# Ensure server user exists
########################################

if id "cs2server" &>/dev/null; then
    echo "User cs2server already exists"
else
    echo "Creating user cs2server"

    if [ -d /home/cs2server ]; then
        useradd -d /home/cs2server -s /bin/bash cs2server
    else
        useradd -m -s /bin/bash cs2server
    fi
fi

########################################
# Run modules (safe execution)
########################################

run_module() {
    MODULE="$1"

    if [ -f "$MODULE" ]; then
        echo ""
        echo "Running module: $MODULE"
        source "$MODULE" || echo "Module $MODULE failed — continuing."
    else
        echo "Skipping missing module: $MODULE"
    fi
}

run_module modules/dependencies.sh
run_module modules/lgsm.sh
run_module modules/metamod.sh
run_module modules/cssharp.sh
run_module modules/database.sh
run_module modules/plugins.sh
run_module modules/admin.sh
run_module modules/cron.sh
#run_module modules/updater.sh

########################################
# Patch gameinfo.gi for Metamod
########################################

GAMEINFO="/home/cs2server/serverfiles/game/csgo/gameinfo.gi"

if [ -f "$GAMEINFO" ]; then
    if grep -q "addons/metamod" "$GAMEINFO"; then
        echo "Metamod path already present in gameinfo.gi"
    else
        echo "Patching gameinfo.gi to load Metamod"
        sed -i '/SearchPaths/a\ \ \ \ Game\tcsgo/addons/metamod' "$GAMEINFO"
    fi
else
    echo "Warning: gameinfo.gi not found"
fi

########################################
# Install server.cfg if missing
########################################

CONFIG="/home/cs2server/serverfiles/game/csgo/cfg/server.cfg"

if [ ! -f "$CONFIG" ]; then
    echo "Installing server.cfg template"

    cp templates/server.cfg "$CONFIG"

    sed -i "s/{{SERVER_NAME}}/${SERVER_NAME:-CS2 Retakes Server}/" "$CONFIG"
    sed -i "s/{{SERVER_TAGS}}/${SERVER_TAGS:-retakes}/" "$CONFIG"
else
    echo "server.cfg already exists — skipping"
fi

########################################
# Restart server so plugins load
########################################

echo ""
echo "Restarting server to activate plugins..."

if [ -f /home/cs2server/cs2server ]; then

    sudo -u cs2server /home/cs2server/cs2server stop || true
    sleep 5

    sudo -u cs2server /home/cs2server/cs2server start || true
    sleep 10

    sudo -u cs2server /home/cs2server/cs2server restart || true

else
    echo "Server binary not found yet — skipping restart"
fi

echo ""
echo "================================="
echo "Install complete"
echo "================================="