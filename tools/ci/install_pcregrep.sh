#!/usr/bin/env bash
set -euo pipefail

source dependencies.sh

curl --output ./pcregrep.deb http://archive.ubuntu.com/ubuntu/pool/universe/p/pcre3/pcregrep_8.39-12build1_amd64.deb
sudo apt -qq install -y ./pcregrep.deb
