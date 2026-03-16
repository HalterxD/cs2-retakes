#!/bin/bash

# Use SCRIPT_DIR from parent script, fallback to current directory
SCRIPT_DIR="${SCRIPT_DIR:-.}"
ENV_FILE="$SCRIPT_DIR/.env"

# Load env if exists
if [ -f "$ENV_FILE" ]; then
    echo "Loading configuration from .env"
    set -a
    source "$ENV_FILE"
    set +a
fi

ask_if_empty() {
    VAR=$1
    QUESTION=$2

    if [ -z "${!VAR:-}" ]; then
        read -rp "$QUESTION: " VALUE
        export $VAR="$VALUE"
    fi
}

ask_if_empty GSLT "Steam GSLT Token"
ask_if_empty SERVER_NAME "Server Name"
ask_if_empty SERVER_TAGS "Server Tags"
# ask_if_empty OWNER_STEAMID "Owner SteamID"
# ask_if_empty ADMINS "Admin SteamIDs (comma separated)"
# ask_if_empty WEBHOOK "Discord Webhook URL (optional)"