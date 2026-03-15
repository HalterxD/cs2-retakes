echo "Checking Metamod..."

META_PATH="/home/cs2server/serverfiles/game/csgo/addons/metamod"

if [ -d "$META_PATH" ]; then
    echo "Metamod already installed. Skipping."
    exit 0
fi


echo "Installing Metamod..."

cd /tmp

MM_URL=$(curl -s https://www.sourcemm.net/downloads.php?branch=master | grep -oP 'https://.*mmsource.*linux.tar.gz' | head -n1)

wget $MM_URL -O metamod.tar.gz

tar -xzf metamod.tar.gz

cp -r addons /home/cs2server/serverfiles/game/csgo/

chown -R cs2server:cs2server /home/cs2server/serverfiles