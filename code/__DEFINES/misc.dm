//for all defines that doesn't fit in any other file.

//Run the world with this parameter to enable a single run though of the game setup and tear down process with unit tests in between
#define TEST_RUN_PARAMETER "test-run"
//Force the log directory to be something specific in the data/logs folder
#define OVERRIDE_LOG_DIRECTORY_PARAMETER "log-directory"
//Prevent the master controller from starting automatically, overrides TEST_RUN_PARAMETER
#define NO_INIT_PARAMETER "no-init"
//Force the config directory to be something other than "config"
#define OVERRIDE_CONFIG_DIRECTORY_PARAMETER "config-directory"

//dirt type for each turf types.
#define NO_DIRT 0
#define DIRT_TYPE_GROUND 1
#define DIRT_TYPE_MARS 2
#define DIRT_TYPE_SNOW 3
#define DIRT_TYPE_LAVALAND 4

///How many variations of bullethole patterns there are
#define BULLETHOLE_STATES 10
///Maximum possible bullet holes in a closed turf
#define BULLETHOLE_MAX 24

//wet floors

#define FLOOR_WET_WATER 1
#define FLOOR_WET_LUBE 2
#define FLOOR_WET_ICE 3

//stages of shoe tying-ness
#define SHOES_TIED 1
#define SHOES_KNOTTED 2

#define RESIZE_DEFAULT_SIZE 1

GLOBAL_VAR_INIT(global_unique_id, 1)
#define UNIQUEID (GLOB.global_unique_id++)

///The icon_state for space.  There is 25 total icon states that vary based on the x/y/z position of the turf
#define SPACE_ICON_STATE(x, y, z) "[((x + y) ^ ~(x * y) + z) % 25]"

// Maploader bounds indices
#define MAP_MINX 1
#define MAP_MINY 2
#define MAP_MINZ 3
#define MAP_MAXX 4
#define MAP_MAXY 5
#define MAP_MAXZ 6

//world/proc/shelleo
#define SHELLEO_ERRORLEVEL 1
#define SHELLEO_STDOUT 2
#define SHELLEO_STDERR 3

//Dummy mob reserve slots
#define DUMMY_HUMAN_SLOT_PREFERENCES "dummy_preference_preview"
#define DUMMY_HUMAN_SLOT_ADMIN "admintools"
#define DUMMY_HUMAN_SLOT_MANIFEST "dummy_manifest_generation"

#define CLIENT_FROM_VAR(I) (ismob(I) ? I:client : (istype(I, /client) ? I : (istype(I, /datum/mind) ? I:current?:client : null)))


#define CHECKBOX_NONE 0
#define CHECKBOX_GROUP 1
#define CHECKBOX_TOGGLE 2


//Ghost orbit types:
#define GHOST_ORBIT_CIRCLE "circle"
#define GHOST_ORBIT_TRIANGLE "triangle"
#define GHOST_ORBIT_HEXAGON "hexagon"
#define GHOST_ORBIT_SQUARE "square"
#define GHOST_ORBIT_PENTAGON "pentagon"


#define GHOST_OTHERS_SIMPLE "white ghost"
#define GHOST_OTHERS_DEFAULT_SPRITE "default sprites"
#define GHOST_OTHERS_THEIR_SETTING "their setting"

#define GHOST_OTHERS_DEFAULT_OPTION GHOST_OTHERS_THEIR_SETTING

#define GHOST_DEFAULT_FORM "ghost"

// Deadchat types
#define DEADCHAT_ANNOUNCEMENT "announcement"
#define DEADCHAT_ARRIVALRATTLE "arrivalrattle"
#define DEADCHAT_DEATHRATTLE "deathrattle"
#define DEADCHAT_REGULAR "regular-deadchat"


//for obj explosion block calculation
#define EXPLOSION_BLOCK_PROC -1

//Luma coefficients suggested for HDTVs. If you change these, make sure they add up to 1.
#define LUMA_R 0.213
#define LUMA_G 0.715
#define LUMA_B 0.072

#define NULL_CLIENT_BUG_CHECK 1
#ifdef NULL_CLIENT_BUG_CHECK
#define CHECK_NULL_CLIENT(X) if(QDELETED(X)) { return; }
#else
#define CHECK_NULL_CLIENT(X) X
#endif

//Misc text define. Does 4 spaces. Used as a makeshift tabulator.
#define FOURSPACES "&nbsp;&nbsp;&nbsp;&nbsp;"

#define RIDING_OFFSET_ALL "ALL"

// The alpha we give to stuff under tiles, if they want it
#define ALPHA_UNDERTILE 128

// For lights.

#define LIGHT_OK 0
#define LIGHT_EMPTY 1
#define LIGHT_BROKEN 2
#define LIGHT_BURNED 3

// shorter way to write as anything
#define AS as anything
