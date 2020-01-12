#!/bin/bash
set -euo pipefail

source dependencies.sh

git clone --depth 1 https://github.com/SpaceManiac/SpacemanDMM.git
cd SpacemanDMM
cargo build --bin $1 --release && cp target/release/$1 ~/$1
cd ~

chmod +x ~/$1
~/$1 --version
