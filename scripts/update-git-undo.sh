#/bin/bash

# This script reverses everything done in update-git.sh. Not recommended to use if there are uncommitted changes.
# Author: rahlzel


CYAN='\033[1;36m' # Light Cyan
NC='\033[0m' # No Color

printf "\n${CYAN}Switch to master branch:${NC}\n"
git checkout master
printf "\n${CYAN}Reset master:${NC}\n"
git reset --hard
printf "\n${CYAN}Switch to DevFreeze:${NC}\n"
git checkout DevFreeze
printf "\n${CYAN}Reset DevFreeze:${NC}\n"
git reset --hard
printf "\n${CYAN}Switch to DevTest:${NC}\n"
git checkout DevTest
printf "\n${CYAN}Reset DevTest:${NC}\n"
git reset --hard

read -p "Done! Press any key to close... " -n1 -s