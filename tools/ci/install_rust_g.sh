#!/usr/bin/env bash
set -euo pipefail

source dependencies.sh

cd ~
git clone https://github.com/tgstation/rust-g.git
cd rust-g
sudo dpkg --add-architecture i386
sudo apt update
sudo apt-get install zlib1g-dev:i386 libssl-dev:i386
rustup target add i686-unknown-linux-gnu
export PKG_CONFIG_ALLOW_CROSS=1
cargo build --release --target i686-unknown-linux-gnu
mkdir -p ~/.byond/bin
cp target/i686-unknown-linux-gnu/release/librust_g.so ~/.byond/bin
chmod +x ~/.byond/bin/librust_g.so
ldd ~/.byond/bin/librust_g.so
