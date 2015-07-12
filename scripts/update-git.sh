#/bin/bash

# This script is best used after a new Pull Request has been accepted. It updates the local repository, merges to DevTest and DevFreeze, then tests a push, but does NOT update Github with anything.
# Author: rahlzel


CYAN='\033[1;36m' # Light Cyan
NC='\033[0m' # No Color

printf "\n${CYAN}Switch to master branch:${NC}\n"
git checkout master
printf "\n${CYAN}Pull master:${NC}\n"
git pull
printf "\n${CYAN}Switch to DevTest branch:${NC}\n"
git checkout DevTest
printf "\n${CYAN}Pull DevTest:${NC}\n"
git pull
printf "\n${CYAN}Switch to DevFreeze branch:${NC}\n"
git checkout DevFreeze
printf "\n${CYAN}Pull DevFreeze:${NC}\n"
git pull

printf "\n${CYAN}Switch to master branch:${NC}\n"
git checkout master

printf "\n${CYAN}Merge DevTest into master:${NC}\n"
git merge DevTest
printf "\n${CYAN}Switch to DevFreeze:${NC}\n"
git checkout DevFreeze
printf "\n${CYAN}Merge DevTest into DevFreeze:${NC}\n"
git merge DevTest
printf "\n${CYAN}Switch back to master:${NC}\n"
git checkout master

printf "\n${CYAN}This is a DRY RUN of a 'git push --all' to test it - no data will be sent:${NC}\n"
git push --all --dry-run
printf "\n${CYAN}If the dry-run passed, do ${NC}git push --all${CYAN} manually after closing this window.${NC}\n"

read -p "Done! Press any key to close... " -n1 -s