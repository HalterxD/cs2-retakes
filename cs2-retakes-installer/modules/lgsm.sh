echo "Installing LGSM..."

sudo -u cs2server bash << 'EOF'

cd ~

wget -O linuxgsm.sh https://linuxgsm.sh
chmod +x linuxgsm.sh

./linuxgsm.sh cs2server

yes Y | ./cs2server install -y

EOF

echo "Configuring GSLT..."

CONFIG="/home/cs2server/lgsm/config-lgsm/cs2server/cs2server.cfg"

mkdir -p $(dirname $CONFIG)

echo "gslt=\"$GSLT\"" >> $CONFIG