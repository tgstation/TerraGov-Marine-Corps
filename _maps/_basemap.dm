//#define LOWMEMORYMODE //uncomment this to load centcom and runtime station and thats it.

#include "map_files\generic\Admin_Level.dmm"

#ifndef LOWMEMORYMODE
	#ifdef ALL_MAPS
		#include "map_files\BigRed_v2\BigRed_v2.dmm"
		#include "map_files\Debugdalus\TGS_Debugdalus.dmm"
		#include "map_files\Ice_Colony_v2\Ice_Colony_v2.dmm"
		#include "map_files\LV624\LV624.dmm"
		#include "map_files\Prison_Station_FOP\Prison_Station_FOP.dmm"
		#include "map_files\Theseus\TGS_Theseus.dmm"
		#include "map_files\Sulaco\Sulaco.dmm"
		#ifdef TRAVISBUILDING
		#endif
	#endif
#endif
