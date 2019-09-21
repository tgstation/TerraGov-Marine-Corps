#!/bin/bash
set -euo pipefail

source dependencies.sh

pip3 install --user PyYaml
pip3 install --user beautifulsoup4

phpenv global $PHP_VERSION
