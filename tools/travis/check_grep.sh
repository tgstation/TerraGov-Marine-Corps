#!/bin/bash
set -euo pipefail

#nb: must be bash to support shopt globstar
shopt -s globstar

st=0

if grep -El '^\".+\" = \(.+\)' _maps/**/*.dmm;	then
    echo "Non-TGM formatted map detected. Please convert it using Map Merger!"
    st=1
fi;
if grep -P '^\ttag = \"icon' _maps/**/*.dmm;	then
    echo "tag vars from icon state generation detected in maps, please remove them."
    st=1
fi;
if grep 'step_[xy]' _maps/**/*.dmm;	then
    echo "step_x/step_y variables detected in maps, please remove them."
    st=1
fi;
if grep 'pixel_[xy] = 0' _maps/**/*.dmm;	then
    echo "pixel_x/pixel_y = 0 variables detected in maps, please review to ensure they are not dirty varedits."
fi;
if grep '^/area/.+[\{]' _maps/**/*.dmm;	then
    echo "Vareditted /area path use detected in maps, please replace with proper paths."
    st=1
fi;
if grep '\W\/turf\s*[,\){]' _maps/**/*.dmm; then
    echo "base /turf path use detected in maps, please replace with proper paths."
    st=1
fi;
if grep '^/*var/' code/**/*.dm; then
    echo "Unmanaged global var use detected in code, please use the helpers."
    st=1
fi;
if grep '^ ' code/**/*.dm; then
    echo "space indentation detected"
    st=1
fi;
if grep '^\t* ' code/**/*.dm; then
    echo "mixed <tab><space> indentation detected"
    st=1
fi;
if pcregrep --buffer-size=100K -LMr '\n$' code/**/*.dm; then
    echo "No newline at end of file detected"
    st=1
fi;
if grep -P '^/[\w/]\S+\(.*(var/|, ?var/.*).*\)' code/**/*.dm; then
    echo "changed files contains proc argument starting with 'var'"
    st=1
fi;
if grep -i 'nanotransen' code/**/*.dm; then
    echo "Misspelling(s) of nanotrasen detected in code, please remove the extra N(s)."
    st=1
fi;
if grep -i 'nanotransen' _maps/**/*.dmm; then
    echo "Misspelling(s) of nanotrasen detected in maps, please remove the extra N(s)."
    st=1
fi;

exit $st
