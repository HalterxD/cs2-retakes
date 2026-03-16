#!/bin/bash
export DEBIAN_FRONTEND=noninteractive
set -euo pipefail

# Always run from installer directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

LOG="logs/installer.log"
mkdir -p logs

exec > >(tee -a "$LOG")
exec 2>&1

echo "==== CS2 Server Manager Installer ===="


########################################
# Load environment configuration
########################################

ENV_LOADED="false"

# Local installer env
if [ -f "$SCRIPT_DIR/.env" ]; then
    echo "Loading environment from $SCRIPT_DIR/.env"
    source "$SCRIPT_DIR/.env"
    ENV_LOADED="true"

# Repo root env
elif [ -f "$SCRIPT_DIR/../.env" ]; then
    echo "Loading environment from repo root .env"
    source "$SCRIPT_DIR/../.env"
    ENV_LOADED="true"

# System env
elif [ -f "$HOME/.cs2servermanager.env" ]; then
    echo "Loading environment from $HOME/.cs2servermanager.env"
    source "$HOME/.cs2servermanager.env"
    ENV_LOADED="true"

else
    echo "No .env file found. Using defaults."
fi

source cli.sh

########################################
# Detect existing installation
########################################

INSTALL_STATE="fresh"

if id "cs2server" &>/dev/null && [ -d "/home/cs2server/serverfiles" ]; then
    INSTALL_STATE="existing"

    echo "Existing CS2 installation detected."

    read -rp "Repair / continue installation? (y/n): " repair

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


source modules/dependencies.sh
source modules/lgsm.sh
source modules/metamod.sh
source modules/cssharp.sh
source modules/database.sh
source modules/cron.sh
source modules/gameinfo.sh
source modules/config.sh
source modules/plugins.sh
# source modules/admin.sh


########################################
# Restart server so plugins load
########################################

echo "Fixing file ownership..."

chown -R cs2server:cs2server /home/cs2server

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