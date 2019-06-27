#!/bin/bash
if [ -n "$1" ]
then
    dme=$1
else
    echo "Specify a DME to check"
    exit 1
fi

if [[ $(awk '/BEGIN_FILE_DIR/{flag=1;next}/END_FILE_DIR/{flag=0}flag' $dme | wc -l) -ne 1 ]]
then
    echo "File DIR was ticked, please untick it, see: https://tgstation13.org/phpBB/viewtopic.php?f=5&t=321 for more"
    exit 1
fi

compile=0
cd ~
if [ -d "SpacemanDMM" ]; then
    cd SpacemanDMM
    git fetch
    if [ $(git rev-parse HEAD) == $(git rev-parse @{u}) ]; then
        compile=1
        git pull
else
    git clone https://github.com/SpaceManiac/SpacemanDMM.git
    cd SpacemanDMM
    compile=1
fi

if [ $compile == 1]; then 
    while true
    do
        echo "heartbeat"
        sleep 60
    done &

    cargo build --verbose -p dreamchecker --release

    kill %1
fi

cd ~/build/tgstation/TerraGov-Marine-Corps
~/SpacemanDMM/target/release/dreamchecker
