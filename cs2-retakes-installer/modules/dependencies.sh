#!/bin/bash

echo "Installing CS2 / LGSM dependencies..."

set -e

dpkg --add-architecture i386

apt update

apt install -y \
bc \
binutils \
bsdmainutils \
bzip2 \
ca-certificates \
cpio \
curl \
distro-info \
file \
gzip \
hostname \
jq \
lib32gcc-s1 \
lib32stdc++6 \
libsdl2-2.0-0:i386 \
netcat-openbsd \
pigz \
python3 \
steamcmd \
tar \
tmux \
unzip \
util-linux \
uuid-runtime \
wget \
xz-utils

echo "Dependencies installed."