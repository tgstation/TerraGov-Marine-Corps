#!/usr/bin/env bash
set -euo pipefail

source dependencies.sh

mkdir -p ~/.byond/bin
cp librust_g.so ~/.byond/bin/librust_g.so
chmod +x ~/.byond/bin/librust_g.so
ldd ~/.byond/bin/librust_g.so
