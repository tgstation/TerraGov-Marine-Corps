/*
The /tg/ codebase allows mixing of hardcoded and dynamically-loaded z-levels.
Z-levels can be reordered as desired and their properties are set by "traits".
See map_config.dm for how a particular station's traits may be chosen.
The list DEFAULT_MAP_TRAITS at the bottom of this file should correspond to
the maps that are hardcoded, as set in _maps/_basemap.dm. SSmapping is
responsible for loading every non-hardcoded z-level.


Multi-Z stations are supported and multi-Z mining and away missions would
require only minor tweaks.
*/

// helpers for modifying jobs, used in various job_changes.dm files
#define MAP_JOB_CHECK if(SSmapping.configs[GROUND_MAP].map_name != JOB_MODIFICATION_MAP_NAME) { return; }
#define MAP_JOB_CHECK_BASE if(SSmapping.configs[GROUND_MAP].map_name != JOB_MODIFICATION_MAP_NAME) { return ..(); }
#define MAP_REMOVE_JOB(jobpath) /datum/job/##jobpath/map_check() { return (SSmapping.configs[GROUND_MAP].map_name != JOB_MODIFICATION_MAP_NAME) && ..() }

#define SPACERUIN_MAP_EDGE_PAD 15

// traits
// boolean - marks a level as having that property if present
#define ZTRAIT_CENTCOM "CentCom"
#define ZTRAIT_STATION "Station"
#define ZTRAIT_RESERVED "Transit/Reserved"
#define ZTRAIT_GROUND "Ground"
#define ZTRAIT_MARINE_MAIN_SHIP "Marine Main Ship"
#define ZTRAIT_DOUBLE_SHIPS "Double Marine Ship"
#define ZTRAIT_AWAY "Away"

// boolean - weather types that occur on the level
#define ZTRAIT_SNOWSTORM "weather_snowstorm"
#define ZTRAIT_ASHSTORM "weather_ashstorm"
#define ZTRAIT_ACIDRAIN "weather_acidrain"
#define ZTRAIT_RAIN "weather_rain"
#define ZTRAIT_SANDSTORM "weather_sandstorm"

// number - bombcap is multiplied by this before being applied to bombs
#define ZTRAIT_BOMBCAP_MULTIPLIER "Bombcap Multiplier"

// number - default gravity if there's no gravity generators or area overrides present
#define ZTRAIT_GRAVITY "Gravity"

// numeric offsets - e.g. {"Down": -1} means that chasms will fall to z - 1 rather than oblivion
#define ZTRAIT_UP "Up"
#define ZTRAIT_DOWN "Down"

// enum - how space transitions should affect this level
#define ZTRAIT_LINKAGE "Linkage"
	// UNAFFECTED if absent - no space transitions
	#define UNAFFECTED null
	// SELFLOOPING - space transitions always self-loop
	#define SELFLOOPING "Self"
	// CROSSLINKED - mixed in with the cross-linked space pool
	#define CROSSLINKED "Cross"

// string - type path of the z-level's baseturf (defaults to space)
#define ZTRAIT_BASETURF "Baseturf"

// default trait definitions, used by SSmapping
#define ZTRAITS_MAIN_SHIP list(ZTRAIT_MARINE_MAIN_SHIP = TRUE)
#define ZTRAITS_GROUND list(ZTRAIT_GROUND = TRUE)
#define ZTRAITS_CENTCOM list(ZTRAIT_CENTCOM = TRUE)
#define ZTRAITS_STATION list(ZTRAIT_LINKAGE = CROSSLINKED, ZTRAIT_STATION = TRUE)
#define ZTRAITS_SPACE list(ZTRAIT_LINKAGE = CROSSLINKED, ZTRAIT_SPACE_RUINS = TRUE)
#define ZTRAITS_LAVALAND list(\
	ZTRAIT_MINING = TRUE, \
	ZTRAIT_LAVA_RUINS = TRUE, \
	ZTRAIT_BOMBCAP_MULTIPLIER = 2, \
	ZTRAIT_BASETURF = /turf/open/lava/smooth/lava_land_surface)
#define ZTRAITS_REEBE list(ZTRAIT_REEBE = TRUE, ZTRAIT_BOMBCAP_MULTIPLIER = 0.5)

#define DL_NAME "name"
#define DL_TRAITS "traits"
#define DECLARE_LEVEL(NAME, TRAITS) list(DL_NAME = NAME, DL_TRAITS = TRAITS)

// must correspond to _basemap.dm for things to work correctly
#define DEFAULT_MAP_TRAITS list(\
	DECLARE_LEVEL("CentCom", ZTRAITS_CENTCOM),\
)

// Camera lock flags
#define CAMERA_LOCK_SHIP (1<<0)
#define CAMERA_LOCK_GROUND (1<<1)
#define CAMERA_LOCK_CENTCOM (1<<2)

//Reserved/Transit turf type
#define RESERVED_TURF_TYPE /turf/open/space/basic			//What the turf is when not being used

//Ruin Generation

#define PLACEMENT_TRIES 100 //How many times we try to fit the ruin somewhere until giving up (really should just swap to some packing algo)

#define PLACE_DEFAULT "random"
#define PLACE_SAME_Z "same"
#define PLACE_SPACE_RUIN "space"
#define PLACE_LAVA_RUIN "lavaland"


#define GROUND_MAP "ground_map"
#define SHIP_MAP "ship_map"
#define ALL_MAPTYPES list(GROUND_MAP, SHIP_MAP)
#define MAP_TO_FILENAME list(GROUND_MAP = "data/next_map.json", SHIP_MAP = "data/next_ship.json")

// traity things
#define MAP_COLD "COLD"

#define MAP_ARMOR_STYLE_DEFAULT "default"
#define MAP_ARMOR_STYLE_ICE "ice"
#define MAP_ARMOR_STYLE_JUNGLE "jungle"
#define MAP_ARMOR_STYLE_PRISON "prison"
#define MAP_ARMOR_STYLE_DESERT "desert"
