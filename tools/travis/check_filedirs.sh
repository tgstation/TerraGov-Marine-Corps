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

cd ~
git clone https://github.com/SpaceManiac/SpacemanDMM.git
cd SpacemanDMM
cargo build -p dreamchecker
cd ~/tgstation/TerraGov-Marine-Corps
if [ ~/SpacemanDMM/target/release/dreamchecker ]; then
  echo "dreamchecker errors found"
  exit 1
fi
