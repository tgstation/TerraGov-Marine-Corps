#!/bin/bash
set -euo pipefail

source dependencies.sh

cd ~
git clone --depth 1 https://github.com/SpaceManiac/SpacemanDMM.git
cd SpacemanDMM
cargo build --bin $1 --release && cp target/release/$1 ~/$1

chmod +x ~/$1
~/$1 --version
