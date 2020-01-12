#!/bin/bash
set -euo pipefail

source dependencies.sh

cd ~
if ![ -d SpacemanDMM ]
then
	git clone -b tgmccitarget --depth 1 https://github.com/spookydonut/SpacemanDMM.git
fi
cd SpacemanDMM
git pull
cargo build --bin $1 --release && cp target/release/$1 ~/$1

chmod +x ~/$1
~/$1 --version
