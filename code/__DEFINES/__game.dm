//Admin perms are in global.dm.

#define DEBUG 0

//Game defining directives.
#define PLANET_Z_LEVEL 4
#define MAIN_SHIP_Z_LEVEL 2 //the main ship
#define LOW_ORBIT_Z_LEVEL 3 //where the Theseus dropships stand when in transit.
#define MAIN_SHIP_AND_DROPSHIPS_Z_LEVELS list(MAIN_SHIP_Z_LEVEL,LOW_ORBIT_Z_LEVEL) //the main ship and the z level where dropships transit
#define ADMIN_Z_LEVEL 1
#define GAME_PLAY_Z_LEVELS list(MAIN_SHIP_Z_LEVEL,LOW_ORBIT_Z_LEVEL,PLANET_Z_LEVEL)
#define MAIN_AI_SYSTEM "ARES v3.2"
#define MAIN_SHIP_ESCAPE_POD_NUMBER 11

#define MAP_ICE_COLONY "Ice Colony"
#define MAP_LV_624 "LV-624"
#define MAP_BIG_RED "Solaris Ridge"
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

//Object specific defines
#define CANDLE_LUM 3 //For how bright candles are


//Preference toggles//
//toggles_sound
#define SOUND_ADMINHELP	1
#define SOUND_MIDI		2
#define SOUND_AMBIENCE	4
#define SOUND_LOBBY		8

//toggles_chat
#define CHAT_OOC			(1 << 0)
#define CHAT_DEAD			(1 << 1)
#define CHAT_GHOSTEARS		(1 << 2)
#define CHAT_GHOSTSIGHT		(1 << 3)
#define CHAT_PRAYER			(1 << 4)
#define CHAT_RADIO			(1 << 5)
#define CHAT_ATTACKLOGS		(1 << 6)
#define CHAT_DEBUGLOGS		(1 << 7)
#define CHAT_GHOSTRADIO 	(1 << 8)
#define SHOW_TYPING 		(1 << 9)
#define CHAT_FFATTACKLOGS 	(1 << 10)
#define CHAT_ENDROUNDLOGS	(1 << 11)
#define CHAT_GHOSTHIVEMIND	(1 << 12)
#define CHAT_STATISTICS		(1 << 13)
//=================================================

#define TOGGLES_CHAT_DEFAULT (CHAT_OOC|CHAT_DEAD|CHAT_GHOSTEARS|CHAT_GHOSTSIGHT|CHAT_PRAYER|CHAT_RADIO|CHAT_ATTACKLOGS|CHAT_GHOSTHIVEMIND|CHAT_STATISTICS)

#define TOGGLES_SOUND_DEFAULT (SOUND_ADMINHELP|SOUND_MIDI|SOUND_AMBIENCE|SOUND_LOBBY)


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

//computer3 error codes, move lower in the file when it passes dev -Sayu
 #define PROG_CRASH      1  // Generic crash
 #define MISSING_PERIPHERAL  2  // Missing hardware
 #define BUSTED_ASS_COMPUTER  4  // Self-perpetuating error.  BAC will continue to crash forever.
 #define MISSING_PROGRAM    8  // Some files try to automatically launch a program.  This is that failing.
 #define FILE_DRM      16  // Some files want to not be copied/moved.  This is them complaining that you tried.
 #define NETWORK_FAILURE  32
//=================================================
//Game mode related defines.

var/list/accessable_z_levels = list("1" = 10, "3" = 10, "4" = 10, "5" = 70)
//This list contains the z-level numbers which can be accessed via space travel and the percentile chances to get there.
//(Exceptions: extended, sandbox and nuke) -Errorage
//Was list("3" = 30, "4" = 70).
//Spacing should be a reliable method of getting rid of a body -- Urist.
//Go away Urist, I'm restoring this to the longer list. ~Errorage

#define TRANSITIONEDGE	3 //Distance from edge to move to another z-level


var/static/list/scarySounds = list('sound/weapons/thudswoosh.ogg','sound/weapons/Taser.ogg','sound/weapons/armbomb.ogg','sound/voice/hiss1.ogg','sound/voice/hiss2.ogg','sound/voice/hiss3.ogg','sound/voice/hiss4.ogg','sound/voice/hiss5.ogg','sound/voice/hiss6.ogg','sound/effects/Glassbr1.ogg','sound/effects/Glassbr2.ogg','sound/effects/Glassbr3.ogg','sound/items/Welder.ogg','sound/items/Welder2.ogg','sound/machines/airlock.ogg','sound/effects/clownstep1.ogg','sound/effects/clownstep2.ogg')
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
