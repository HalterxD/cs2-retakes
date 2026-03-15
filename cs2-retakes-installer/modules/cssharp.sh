echo "Checking CounterStrikeSharp..."

CSS_PATH="/home/cs2server/serverfiles/game/csgo/addons/counterstrikesharp"

if [ -d "$CSS_PATH" ]; then
    echo "CounterStrikeSharp already installed. Skipping."
    return

echo "Installing CounterStrikeSharp..."

LATEST=$(curl -s https://api.github.com/repos/roflmuffin/CounterStrikeSharp/releases/latest \
 | jq -r '.assets[] | select(.name|test("linux")) | .browser_download_url')

cd /tmp

wget $LATEST -O cssharp.zip

unzip cssharp.zip

cp -r addons /home/cs2server/serverfiles/game/csgo/

chown -R cs2server:cs2server /home/cs2server/serverfiles