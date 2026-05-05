#!/bin/bash

# Special file to ensure all dependencies still exist between server launches.
# Mainly for use by people who abuse docker by modifying the container's system.
# we dont need this, and it breaks because you need to pass arguemnts to installdeps.sh
# ./InstallDeps.sh
