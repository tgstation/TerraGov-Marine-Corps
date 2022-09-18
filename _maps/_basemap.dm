//#define LOWMEMORYMODE //uncomment this to load centcom and runtime station and thats it.

#include "map_files\generic\Admin_Level.dmm"

#ifndef LOWMEMORYMODE
	#ifdef ALL_MAPS
		#include "map_files\BigRed_v2\BigRed_v2.dmm"
		#include "map_files\Debugdalus\TGS_Debugdalus.dmm"
		#include "map_files\desertdam\desertdam.dmm"
		#include "map_files\Ice_Colony_v2\Ice_Colony_v2.dmm"
		#include "map_files\LV624\LV624.dmm"
		#include "map_files\Prison_Station_FOP\Prison_Station_FOP.dmm"
		#include "map_files\Theseus\TGS_Theseus.dmm"
		#include "map_files\Vapor_Processing\Vapor_Processing.dmm"
		#include "map_files\Sulaco\Sulaco.dmm"
		#include "map_files\Pillar_of_Spring\TGS_Pillar_of_Spring.dmm"
		#include "map_files\icy_caves\icy_caves.dmm"
		#include "map_files\Sulaco\Sulaco.dmm"
		#include "map_files\Research_Outpost\Research_Outpost.dmm"
		#include "map_files\Magmoor_Digsite_IV\Magmoor_Digsite_IV.dmm"
		#include "map_files\Orion_Military_Outpost\orionoutpost.dmm"
		#include "map_files\Twin_Pillars\Twin_Pillars.dmm"
		#include "map_files\Minerva\TGS_Minerva.dmm"
		#include "map_files\gelida_iv\gelida_iv.dmm"
		#include "map_files\Rocinante_Base\sombase.dmm"
		#ifdef CIBUILDING
			#include "templates.dm"
		#endif
	#endif
#endif
