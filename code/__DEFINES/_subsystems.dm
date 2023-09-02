//Update this whenever the db schema changes
//make sure you add an update to the schema_version stable in the db changelog
#define DB_MAJOR_VERSION 2
#define DB_MINOR_VERSION 1

//Timing subsystem
//Don't run if there is an identical unique timer active
//if the arguments to addtimer are the same as an existing timer, it doesn't create a new timer, and returns the id of the existing timer
#define TIMER_UNIQUE (1<<0)
//For unique timers: Replace the old timer rather then not start this one
#define TIMER_OVERRIDE (1<<1)
//Timing should be based on how timing progresses on clients, not the sever.
//	tracking this is more expensive,
//	should only be used in conjuction with things that have to progress client side, such as animate() or sound()
#define TIMER_CLIENT_TIME (1<<2)
//Timer can be stopped using deltimer()
#define TIMER_STOPPABLE (1<<3)
//To be used with TIMER_UNIQUE
//prevents distinguishing identical timers with the wait variable
#define TIMER_NO_HASH_WAIT (1<<4)
//Loops the timer repeatedly until qdeleted
//In most cases you want a subsystem instead
#define TIMER_LOOP (1<<5)

///Delete the timer on parent datum Destroy() and when deltimer'd
#define TIMER_DELETE_ME (1<<6)

#define TIMER_ID_NULL -1

/// Used to trigger object removal from a processing list
#define PROCESS_KILL 26

//For servers that can't do with any additional lag, set this to none in flightpacks.dm in subsystem/processing.
#define FLIGHTSUIT_PROCESSING_NONE 0
#define FLIGHTSUIT_PROCESSING_FULL 1

#define INITIALIZATION_INSSATOMS 0	//New should not call Initialize
#define INITIALIZATION_INNEW_MAPLOAD 2	//New should call Initialize(TRUE)
#define INITIALIZATION_INNEW_REGULAR 1	//New should call Initialize(FALSE)

#define INITIALIZE_HINT_NORMAL 0    //Nothing happens
#define INITIALIZE_HINT_LATELOAD 1  //Call LateInitialize
#define INITIALIZE_HINT_QDEL 2  //Call qdel on the atom
///Call qdel with a force of TRUE after initialization
#define INITIALIZE_HINT_QDEL_FORCE 3

//type and all subtypes should always call Initialize in New()
#define INITIALIZE_IMMEDIATE(X) ##X/New(loc, ...){\
	..();\
	if(!(flags_atom & INITIALIZED)) {\
		args[1] = TRUE;\
		SSatoms.InitAtom(src, FALSE, args);\
	}\
}

//! ### SS initialization hints
/**
 * Negative values incidate a failure or warning of some kind, positive are good.
 * 0 and 1 are unused so that TRUE and FALSE are guarenteed to be invalid values.
 */

/// Subsystem failed to initialize entirely. Print a warning, log, and disable firing.
#define SS_INIT_FAILURE -2

/// The default return value which must be overriden. Will succeed with a warning.
#define SS_INIT_NONE -1

/// Subsystem initialized sucessfully.
#define SS_INIT_SUCCESS 2

/// Successful, but don't print anything. Useful if subsystem was disabled.
#define SS_INIT_NO_NEED 3

//! ### SS initialization load orders
// Subsystem init_order, from highest priority to lowest priority
// Subsystems shutdown in the reverse of the order they initialize in
// The numbers just define the ordering, they are meaningless otherwise.

#define INIT_ORDER_GARBAGE 27
#define INIT_ORDER_DBCORE 25
#define INIT_ORDER_SERVER_MAINT 23
#define INIT_ORDER_INPUT 21
#define INIT_ORDER_SOUNDS 19
#define INIT_ORDER_INSTRUMENTS 17
#define INIT_ORDER_GREYSCALE 16
#define INIT_ORDER_CODEX 15
#define INIT_ORDER_EVENTS 14
#define INIT_ORDER_MONITOR 13
#define INIT_ORDER_JOBS 12
#define INIT_ORDER_TICKER 11
#define INIT_ORDER_MAPPING 10
#define INIT_ORDER_EARLY_ASSETS 9
#define INIT_ORDER_SPATIAL_GRID 8
#define INIT_ORDER_PERSISTENCE 7 //before assets because some assets take data from SSPersistence, such as vendor items
#define INIT_ORDER_TTS 6
#define INIT_ORDER_ATOMS 5
#define INIT_ORDER_MODULARMAPPING 4
#define INIT_ORDER_MACHINES 3
#define INIT_ORDER_AI_NODES 2
#define INIT_ORDER_TIMER 1
#define INIT_ORDER_DEFAULT 0
#define INIT_ORDER_AIR -1
#define INIT_ORDER_ASSETS -4
#define INIT_ORDER_SPAWNING_POOL -5
#define INIT_ORDER_OVERLAY -6
#define INIT_ORDER_STICKY_BAN -10
#define INIT_ORDER_MINIMAPS -15
#define INIT_ORDER_ICON_SMOOTHING -16
#define INIT_ORDER_LIGHTING -20
#define INIT_ORDER_SHUTTLE -21
#define INIT_ORDER_PATH -50
#define INIT_ORDER_EXPLOSIONS -69
#define INIT_ORDER_EXCAVATION -78
#define INIT_ORDER_STATPANELS -97
#define INIT_ORDER_CHAT -100 //Should be last to ensure chat remains smooth during init.

// Subsystem fire priority, from lowest to highest priority
// If the subsystem isn't listed here it's either DEFAULT or PROCESS (if it's a processing subsystem child)

#define FIRE_PRIORITY_ACTION_STATES 5
#define FIRE_PRIORITY_PING 10
#define FIRE_PRIORITY_IDLE_NPC 10
#define FIRE_PRIORITY_ADVANCED_PATHFINDING 10
#define FIRE_PRIORITY_SERVER_MAINT 10
#define FIRE_PRIORITY_AMBIENCE 10
#define FIRE_PRIORITY_WEED 11
#define FIRE_PRIORITY_GARBAGE 15
#define FIRE_PRIORITY_MINIMAPS 17
#define FIRE_PRIORITY_DIRECTION 19
#define FIRE_PRIORITY_SPAWNING 20
#define FIRE_PRIORITY_AIR 20
#define FIRE_PRIORITY_NPC 20
#define FIRE_PRIORITY_PROCESS 25
#define FIRE_PRIORITY_OBJ 40
#define FIRE_PRIORITY_DEFAULT 50
#define FIRE_PRIORITY_SMOOTHING 60
#define FIRE_PRIORITY_PARALLAX 65
#define FIRE_PRIORITY_INSTRUMENTS 80
#define FIRE_PRIORITY_POINTS 90
#define FIRE_PRIORITY_SILO 91
#define FIRE_PRIORITY_PATHFINDING 95
#define FIRE_PRIORITY_MOBS 100
#define FIRE_PRIORITY_ASSETS 105
#define FIRE_PRIORITY_TGUI 110
#define FIRE_PRIORITY_TICKER 200
#define FIRE_PRIORITY_STATPANEL 390
#define FIRE_PRIORITY_CHAT 400
#define FIRE_PRIORITY_LOOPINGSOUND 405
#define FIRE_PRIORITY_RUNECHAT 410
#define FIRE_PRIORITY_TTS 425
#define FIRE_PRIORITY_AUTOFIRE 450
#define FIRE_PRIORITY_OVERLAYS 500
#define FIRE_PRIORITY_EXPLOSIONS 666
#define FIRE_PRIORITY_TIMER 700
#define FIRE_PRIORITY_SPEECH_CONTROLLER 900
#define FIRE_PRIORITY_INPUT 1000 // This must always always be the max highest priority. Player input must never be lost.

// SS runlevels

#define RUNLEVEL_INIT 0
#define RUNLEVEL_LOBBY 1
#define RUNLEVEL_SETUP 2
#define RUNLEVEL_GAME 4
#define RUNLEVEL_POSTGAME 8

#define RUNLEVELS_DEFAULT (RUNLEVEL_SETUP | RUNLEVEL_GAME | RUNLEVEL_POSTGAME)



/// Explosion Subsystem subtasks
#define SSEXPLOSIONS_MOVABLES 1
#define SSEXPLOSIONS_TURFS 2
#define SSEXPLOSIONS_THROWS 3

/**
	Create a new timer and add it to the queue.
	* Arguments:
	* * callback the callback to call on timer finish
	* * wait deciseconds to run the timer for
	* * flags flags for this timer, see: code\__DEFINES\subsystems.dm
*/
#define addtimer(args...) _addtimer(args, file = __FILE__, line = __LINE__)

/// The timer key used to know how long subsystem initialization takes
#define SS_INIT_TIMER_KEY "ss_init"
