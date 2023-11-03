#define DEBUG 0

//Game defining directives.
#define MAIN_AI_SYSTEM "ARES v3.2"

#define MAP_BIG_RED "Big Red"
#define MAP_ICE_COLONY "Ice Colony"
#define MAP_ICY_CAVES "Icy Caves"
#define MAP_LV_624 "LV624"
#define MAP_PRISON_STATION "Prison Station"
#define MAP_RESEARCH_OUTPOST "Research Outpost"
#define MAP_WHISKEY_OUTPOST "Whiskey Outpost"
#define MAP_MAGMOOR_DIGSITE "Magmoor Digsite IV"
#define MAP_GELIDA_IV "Gelida IV"
#define MAP_DELTA_STATION "Delta Station"
#define MAP_OSCAR_OUTPOST "Oscar Outpost"

#define MAP_PILLAR_OF_SPRING "Pillar of Spring"
#define MAP_SULACO "Sulaco"
#define MAP_THESEUS "Theseus"
#define MAP_ARACHNE "Arachne"
#define MAP_COMBAT_PATROL_BASE "Combat Patrol Base"

#define MAP_FORT_PHOBOS "Fort Phobos"
#define MAP_ITERON "Iteron"


#define SEE_INVISIBLE_MINIMUM 5

#define INVISIBILITY_LIGHTING 20

#define SEE_INVISIBLE_LIVING 25

#define INVISIBILITY_OBSERVER 60
#define SEE_INVISIBLE_OBSERVER 60

#define INVISIBILITY_MAXIMUM 100

#define INVISIBILITY_ABSTRACT 101 //only used for abstract objects (e.g. spacevine_controller), things that are not really there.


//Object specific defines
#define CANDLE_LUM 3 //For how bright candles are

#define SEC_LEVEL_GREEN 0
#define SEC_LEVEL_BLUE 1
#define SEC_LEVEL_RED 2
#define SEC_LEVEL_DELTA 3


//=================================================
#define HOSTILE_STANCE_IDLE 1
#define HOSTILE_STANCE_ALERT 2
#define HOSTILE_STANCE_ATTACK 3
#define HOSTILE_STANCE_ATTACKING 4
#define HOSTILE_STANCE_TIRED 5
//=================================================


//=================================================
//Game mode related defines.

#define TRANSITIONEDGE 3 //Distance from edge to move to another z-level

//Flags for zone sleeping
#define ZONE_ACTIVE 1
#define ZONE_SLEEPING 0
#define GET_RANDOM_FREQ rand(32000, 55000) //Frequency stuff only works with 45kbps oggs.

//ceiling types
#define CEILING_NONE 0
#define CEILING_GLASS 1
#define CEILING_METAL 2
#define CEILING_OBSTRUCTED 3
#define CEILING_UNDERGROUND 4
#define CEILING_UNDERGROUND_METAL 5
#define CEILING_DEEP_UNDERGROUND 6
#define CEILING_DEEP_UNDERGROUND_METAL 6


// Default font settings
#define FONT_SIZE "5pt"
#define FONT_COLOR "#09f"
#define FONT_STYLE "Arial Black"
#define SCROLL_SPEED 2

// Default preferences
#define DEFAULT_SPECIES "Human"

#define GAME_YEAR (text2num(time2text(world.realtime, "YYYY")) + 395)


#define MAX_MESSAGE_LEN 1024
#define MAX_PAPER_MESSAGE_LEN 3072
#define MAX_BOOK_MESSAGE_LEN 9216
#define MAX_NAME_LEN 26
#define MAX_BROADCAST_LEN 512
#define MAX_NAME_HYPO 3


//for whether AI eyes see static, and whether it is mouse-opaque or not
#define USE_STATIC_NONE 0
#define USE_STATIC_TRANSPARENT 1
#define USE_STATIC_OPAQUE 2


#define CINEMATIC_DEFAULT 1
#define CINEMATIC_SELFDESTRUCT 2
#define CINEMATIC_SELFDESTRUCT_MISS 3
#define CINEMATIC_NUKE_WIN 4
#define CINEMATIC_NUKE_MISS 5
#define CINEMATIC_ANNIHILATION 6
#define CINEMATIC_MALF 7
#define CINEMATIC_NUKE_FAKE 8
#define CINEMATIC_NUKE_NO_CORE 9
#define CINEMATIC_NUKE_FAR 10
#define CINEMATIC_CRASH_NUKE 11

#define WORLD_VIEW "15x15"
#define WORLD_VIEW_NUM 7
#define VIEW_NUM_TO_STRING(v) "[1 + 2 * v]x[1 + 2 * v]"

#define TEXT_NORTH "[NORTH]"
#define TEXT_SOUTH "[SOUTH]"
#define TEXT_EAST "[EAST]"
#define TEXT_WEST "[WEST]"
