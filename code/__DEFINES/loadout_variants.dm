
//Do not change these defines
#define NORMAL "normal"
#define CAPE_SCARF_ROUND "cape_scarf_round"
#define CAPE_SCARF_TIED "cape_scarf_tied"
#define CAPE_SCARF "cape_scarf"
#define CAPE_SHORT "cape_short"
#define SOM_BLACK "SOM_black"
#define CAPE_HIGHLIGHT_NORMAL_ALT "normal_alt"

#define CAPE_HIGHLIGHT_NONE "cape_highlight_none"
#define LEATHER_JACKET_WEBBING "leather_jacket_webbing"

// Hardsuit Helmet Variants
#define FOUR_EYE_FACEPLATE "four_eye_faceplate"
#define FOUR_EYE_FACEPLATE_VISOR "four_eye_faceplate_visor"

// Ballistic Vest Variants
#define BALLISTIC_VEST_URBAN "ballistic_vest_urban"
#define BALLISTIC_VEST_DESERT "ballistic_vest_desert"
#define BALLISTIC_VEST_JUNGLE "ballistic_vest_jungle"
#define BALLISTIC_VEST_SNOW "ballistic_vest_snow"

// Each key AND value HAS to be unique.
///saved loadout key = icon_state, AGAIN DO NOT EDIT THE KEYS IT WILL BREAK LOADOUTS
GLOBAL_LIST_INIT(loadout_variant_keys, list(
	NORMAL = "normal",
	CAPE_SCARF_ROUND = "scarf round",
	CAPE_SCARF_TIED = "scarf tied",
	CAPE_SCARF = "scarf",
	CAPE_SHORT = "short",
	CAPE_HIGHLIGHT_NONE = "none",
	LEATHER_JACKET_WEBBING = "webbing",
	SOM_BLACK = "black",
	CAPE_HIGHLIGHT_NORMAL_ALT = "normal (alt)",
	MARK_FIVE_WEBBING = "webbing",
	MARK_THREE_WEBBING = "webbing",
	MARK_ONE_WEBBING = "webbing",
	FOUR_EYE_FACEPLATE = "Four Eye",
	FOUR_EYE_FACEPLATE_VISOR = "Four Eye",
	BALLISTIC_VEST_URBAN = "urban",
	BALLISTIC_VEST_JUNGLE = "jungle",
	BALLISTIC_VEST_DESERT = "desert",
	BALLISTIC_VEST_SNOW = "snow",
))
