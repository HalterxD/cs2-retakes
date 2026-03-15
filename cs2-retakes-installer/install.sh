# #!/bin/bash

# set -euo pipefail

# LOG="/var/log/cs2-installer.log"

# exec > >(tee -a $LOG)
# exec 2>&1

# echo "Starting CS2 Retakes Installer"

# read -p "Enter GSLT Token: " GSLT
# read -p "Server Owner SteamID: " OWNER_STEAMID

# export GSLT
# export OWNER_STEAMID

# if ! id "cs2server" &>/dev/null; then
#     useradd -m cs2server
# fi

# cd "$(dirname "$0")"

# source modules/dependencies.sh
# source modules/lgsm.sh
# source modules/metamod.sh
# source modules/cssharp.sh
# source modules/database.sh
# source modules/cron.sh

# echo "Installation complete"


#!/bin/bash

set -euo pipefail

LOG="logs/installer.log"
mkdir -p logs

exec > >(tee -a $LOG)
exec 2>&1

source cli.sh

if id "cs2server" &>/dev/null; then
  echo "Existing install detected"
  read -p "Repair existing install? (y/n): " repair
fi

if ! id "cs2server" &>/dev/null; then
  useradd -m cs2server
fi

source modules/dependencies.sh
source modules/lgsm.sh
source modules/metamod.sh
source modules/cssharp.sh
source modules/database.sh
source modules/plugins.sh
source modules/admin.sh
source modules/cron.sh
#source modules/updater.sh


CONFIG="/home/cs2server/serverfiles/game/csgo/cfg/server.cfg"

cp templates/server.cfg $CONFIG

sed -i "s/{{SERVER_NAME}}/$SERVER_NAME/" $CONFIG
sed -i "s/{{SERVER_TAGS}}/$SERVER_TAGS/" $CONFIG

echo "Install complete"