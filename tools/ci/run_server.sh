#!/bin/bash
set -euo pipefail

tools/deploy.sh ci_test
rm ci_test/*.dll
mkdir -p ci_test/config

#test config
cp tools/ci/ci_config.txt ci_test/config/config.txt
cp config/maps.txt ci_test/config/maps.txt
cp config/shipmaps.txt ci_test/config/shipmaps.txt

cd ci_test
DreamDaemon tgmc.dmb -close -trusted -verbose -params "log-directory=ci"
cd ..
cat ci_test/data/logs/ci/clean_run.lk
