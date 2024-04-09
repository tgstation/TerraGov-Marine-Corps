#!/bin/bash
set -euo pipefail

tools/deploy.sh ci_test
mkdir ci_test/config

#test config
cp tools/ci/ci_config.txt ci_test/config/config.txt

cd ci_test
DreamDaemon tgmc.dmb -close -trusted -verbose -params "log-directory=ci"
cd ..
cat ci_test/data/logs/ci/clean_run.lk
cp config/maps.txt ci_test/config/maps.txt
cp config/shipmaps.txt ci_test/config/shipmaps.txt
