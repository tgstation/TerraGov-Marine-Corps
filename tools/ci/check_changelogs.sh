#!/bin/bash
set -euo pipefail

md5sum -c - <<< "9889cdbcb2a2ed07947f1d36a1e0540f *html/changelogs/example.yml"
python3 .github/ss13_genchangelog.py html/changelogs
