#!/bin/bash

#nb: must be bash to support shopt globstar
set -e
shopt -s globstar

if [ "$BUILD_TOOLS" = false ]; then
	if grep -E '^\".+\" = \(.+\)' _maps/**/*.dmm;	then
    	echo "Non-TGM formatted map detected. Please convert it using Map Merger!"
    	exit 1
	fi;
	if grep 'step_[xy]' _maps/**/*.dmm;	then
    	echo "step_x/step_y variables detected in maps, please remove them."
    	exit 1
	fi;
	if grep 'pixel_[xy] = 0' _maps/**/*.dmm;	then
    	echo "pixel_x/pixel_y = 0 variables detected in maps, please review to ensure they are not dirty varedits."
	fi;
	if grep '^/area/.+[\{]' _maps/**/*.dmm;	then
    	echo "Vareditted /area path use detected in maps, please replace with proper paths."
    	exit 1
	fi;
	if grep '\W\/turf\s*[,\){]' _maps/**/*.dmm; then
    	echo "base /turf path use detected in maps, please replace with proper paths."
    	exit 1
	fi;

    (! grep 'step_[xy]' _maps/**/*.dmm)
    source $HOME/BYOND-${BYOND_MAJOR}.${BYOND_MINOR}/byond/bin/byondsetup
    tools/travis/dm.sh -DALL_MAPS tgmc.dme
fi;
