#!/bin/bash

#Run this in the repo root after compiling
#First arg is path to where you want to deploy
#creates a work tree free of everything except what's necessary to run the game

#second arg is working directory if necessary
if [[ $# -eq 2 ]] ; then
  cd $2
fi

mkdir -p \
    $1/_maps \
    $1/icons \
    $1/strings \
    $1/config

if [ -d ".git" ]; then
  mkdir -p $1/.git/logs
  cp -r .git/logs/* $1/.git/logs/
fi

cp tgmc.dmb tgmc.rsc $1/
cp -r config/* $1/config/
cp -r _maps/* $1/_maps/
cp -r strings/* $1/strings/
cp config/maps.txt $1/config/maps.txt
cp config/shipmaps.txt $1/config/maps.txt

#remove .dm files from _maps

#this regrettably doesn't work with windows find
#find $1/_maps -name "*.dm" -type f -delete

#dlls on windows
cp rust_g* $1/ || true
cp *BSQL.* $1/ || true
