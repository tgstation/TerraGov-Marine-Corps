#define DEBUG 0

//Game defining directives.
#define MAIN_AI_SYSTEM "ARES v3.2"
#define MAIN_SHIP_ESCAPE_POD_NUMBER 11

#define MAP_ICE_COLONY "Ice Colony"
#define MAP_LV_624 "LV624"
#define MAP_BIG_RED "Big Red"
#define MAP_PRISON_STATION "Prison Station"
#define MAP_WHISKEY_OUTPOST "Whiskey Outpost"

/*
Trash Authority Directives
Defines for when we need to give commands to the trash authority in how to handle trash.
These are used with cdel (clean delete). For example, qdel(atom, TA_REVIVE_ME) would tell the TA to throw the atom into the recycler.
*/
#define TA_TRASH_ME		1 //Trash it.
#define TA_REVIVE_ME	2 //Not killing this one, instead adding it to the recycler. Call this on bullets, for example.
#define TA_PURGE_ME		3 //Purge it, but later. Not different from adding it to queue regularly as the trash authority will incinerate it when possible.
#define TA_PURGE_ME_NOW	4 //Purge it immediately. Generally don't want to use this.
#define TA_IGNORE_ME	5 //Ignore this atom, don't do anything with it. In case the atom will die on its own or something.
					 	  //Shouldn't usually use this as garbage collection is far better.

#define SEE_INVISIBLE_MINIMUM 5

#define SEE_INVISIBLE_OBSERVER_NOLIGHTING 15

#define INVISIBILITY_LIGHTING 20

#define SEE_INVISIBLE_LIVING 25

#define SEE_INVISIBLE_LEVEL_ONE 35	//Used by some stuff in code. It's really poorly organized.
#define INVISIBILITY_LEVEL_ONE 35	//Used by some stuff in code. It's really poorly organized.

#define SEE_INVISIBLE_LEVEL_TWO 45	//Used by some other stuff in code. It's really poorly organized.
#define INVISIBILITY_LEVEL_TWO 45	//Used by some other stuff in code. It's really poorly organized.

#define INVISIBILITY_OBSERVER 60
#define SEE_INVISIBLE_OBSERVER 60

#define INVISIBILITY_MAXIMUM 100

#define INVISIBILITY_ABSTRACT 101 //only used for abstract objects (e.g. spacevine_controller), things that are not really there.


//Object specific defines
#define CANDLE_LUM 3 //For how bright candles are

/*
	Shuttles
*/

// these define the time taken for the shuttle to get to SS13
// and the time before it leaves again
// note that this is multiplied by 10 in the shuttle controller. Hence, this is not defined in deciseconds but in real seconds

#define DOCK_ATTEMPT_TIMEOUT 200	//how long in ticks we wait before assuming the docking controller is broken or blown up.
#define SHUTTLE_PREPTIME 				600	// 10 minutes = 600 seconds - after this time, the shuttle departs centcom and cannot be recalled
#define SHUTTLE_LEAVETIME 				180	// 3 minutes = 180 seconds - the duration for which the shuttle will wait at the station after arriving
#define SHUTTLE_TRANSIT_DURATION		600	// 10 minutes = 600 seconds - how long it takes for the shuttle to get to the station
#define SHUTTLE_TRANSIT_DURATION_RETURN 100	// 100 seconds
#define DROPSHIP_TRANSIT_DURATION		100	// 100 seconds
#define DROPPOD_TRANSIT_DURATION		50	// 50 seconds
#define ELEVATOR_TRANSIT_DURATION		5	// 5 seconds
#define DROPSHIP_CRASH_TRANSIT_DURATION	180	// 180 seconds. 3 minutes

#define SHUTTLE_RECHARGE  1200 // 2 minutes
#define ELEVATOR_RECHARGE 150  // 15 seconds

//Shuttle moving status
#define SHUTTLE_IDLE		0
#define SHUTTLE_WARMUP		1
#define SHUTTLE_INTRANSIT	2
#define SHUTTLE_CRASHED		3

//Ferry shuttle processing status
#define IDLE_STATE		0
#define WAIT_LAUNCH		1
#define FORCE_LAUNCH	2
#define WAIT_ARRIVE		3
#define WAIT_FINISH		4
#define FORCE_CRASH		5

//Security levels
#define SEC_LEVEL_GREEN	0
#define SEC_LEVEL_BLUE	1
#define SEC_LEVEL_RED	2
#define SEC_LEVEL_DELTA	3

//Alarm levels.
#define ALARM_WARNING_FIRE 	1
#define ALARM_WARNING_ATMOS	2
#define ALARM_WARNING_EVAC	4
#define ALARM_WARNING_READY	8
#define ALARM_WARNING_DOWN	16

//some arbitrary defines to be used by self-pruning global lists. (see master_controller)
#define PROCESS_KILL 26	//Used to trigger removal from a processing list

//=================================================
#define HOSTILE_STANCE_IDLE 1
#define HOSTILE_STANCE_ALERT 2
#define HOSTILE_STANCE_ATTACK 3
#define HOSTILE_STANCE_ATTACKING 4
#define HOSTILE_STANCE_TIRED 5
//=================================================


//=================================================
//Game mode related defines.

var/list/accessable_z_levels = list("1" = 10, "3" = 10, "4" = 10, "5" = 70)
//This list contains the z-level numbers which can be accessed via space travel and the percentile chances to get there.
//(Exceptions: extended, sandbox and nuke) -Errorage
//Was list("3" = 30, "4" = 70).
//Spacing should be a reliable method of getting rid of a body -- Urist.
//Go away Urist, I'm restoring this to the longer list. ~Errorage

#define TRANSITIONEDGE	3 //Distance from edge to move to another z-level

//Flags for zone sleeping
#define ZONE_ACTIVE 1
#define ZONE_SLEEPING 0
#define GET_RANDOM_FREQ rand(32000, 55000) //Frequency stuff only works with 45kbps oggs.

//ceiling types
#define CEILING_NONE 0
#define CEILING_GLASS 1
#define CEILING_METAL 2
#define CEILING_UNDERGROUND 3
#define CEILING_UNDERGROUND_METAL 4
#define CEILING_DEEP_UNDERGROUND 5
#define CEILING_DEEP_UNDERGROUND_METAL 5

// Default font settings
#define FONT_SIZE "5pt"
#define FONT_COLOR "#09f"
#define FONT_STYLE "Arial Black"
#define SCROLL_SPEED 2

// Default preferences
#define DEFAULT_SPECIES "Human"

#define GAME_YEAR 2415


#define MAX_MESSAGE_LEN 1024
#define MAX_PAPER_MESSAGE_LEN 3072
#define MAX_BOOK_MESSAGE_LEN 9216
#define MAX_NAME_LEN 26