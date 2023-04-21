//! Defines for subsystems and overlays
//!
//! Lots of important stuff in here, make sure you have your brain switched on
//! when editing this file

//! ## DB defines
/**
 * DB major schema version
 *
 * Update this whenever the db schema changes
 *
 * make sure you add an update to the schema_version stable in the db changelog
 */
#define DB_MAJOR_VERSION 5

/**
 * DB minor schema version
 *
 * Update this whenever the db schema changes
 *
 * make sure you add an update to the schema_version stable in the db changelog
 */
#define DB_MINOR_VERSION 23


//! ## Timing subsystem
/**
 * Don't run if there is an identical unique timer active
 *
 * if the arguments to addtimer are the same as an existing timer, it doesn't create a new timer,
 * and returns the id of the existing timer
 */
#define TIMER_UNIQUE (1<<0)

///For unique timers: Replace the old timer rather then not start this one
#define TIMER_OVERRIDE (1<<1)

/**
 * Timing should be based on how timing progresses on clients, not the server.
 *
 * Tracking this is more expensive,
 * should only be used in conjuction with things that have to progress client side, such as
 * animate() or sound()
 */
#define TIMER_CLIENT_TIME (1<<2)

///Timer can be stopped using deltimer()
#define TIMER_STOPPABLE (1<<3)

///prevents distinguishing identical timers with the wait variable
///
///To be used with TIMER_UNIQUE
#define TIMER_NO_HASH_WAIT (1<<4)

///Loops the timer repeatedly until qdeleted
///
///In most cases you want a subsystem instead, so don't use this unless you have a good reason
#define TIMER_LOOP (1<<5)

///Delete the timer on parent datum Destroy() and when deltimer'd
#define TIMER_DELETE_ME (1<<6)

///Empty ID define
#define TIMER_ID_NULL -1

/// Used to trigger object removal from a processing list
#define PROCESS_KILL 26


//! ## Initialization subsystem

///New should not call Initialize
#define INITIALIZATION_INSSATOMS 0
///New should call Initialize(TRUE)
#define INITIALIZATION_INNEW_MAPLOAD 2
///New should call Initialize(FALSE)
#define INITIALIZATION_INNEW_REGULAR 1

//! ### Initialization hints

///Nothing happens
#define INITIALIZE_HINT_NORMAL 0
/**
 * call LateInitialize at the end of all atom Initalization
 *
 * The item will be added to the late_loaders list, this is iterated over after
 * initalization of subsystems is complete and calls LateInitalize on the atom
 * see [this file for the LateIntialize proc](atom.html#proc/LateInitialize)
 */
#define INITIALIZE_HINT_LATELOAD 1

///Call qdel on the atom after intialization
#define INITIALIZE_HINT_QDEL 2

///type and all subtypes should always immediately call Initialize in New()
#define INITIALIZE_IMMEDIATE(X) ##X/New(loc, ...){\
	..();\
	if(!(flags_1 & INITIALIZED_1)) {\
		var/previous_initialized_value = SSatoms.initialized;\
		SSatoms.initialized = INITIALIZATION_INNEW_MAPLOAD;\
		args[1] = TRUE;\
		SSatoms.InitAtom(src, FALSE, args);\
		SSatoms.initialized = previous_initialized_value;\
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
#define INIT_ORDER_TICKER 10
#define INIT_ORDER_MAPPING 9
#define INIT_ORDER_SPATIAL_GRID 8
#define INIT_ORDER_PERSISTENCE 7 //before assets because some assets take data from SSPersistence, such as vendor items
#define INIT_ORDER_ATOMS 6
#define INIT_ORDER_MODULARMAPPING 5
#define INIT_ORDER_MACHINES 4
#define INIT_ORDER_AI_NODES 3
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
#define FIRE_PRIORITY_TGUI 110
#define FIRE_PRIORITY_TICKER 200
#define FIRE_PRIORITY_STATPANEL 390
#define FIRE_PRIORITY_CHAT 400
#define FIRE_PRIORITY_LOOPINGSOUND 405
#define FIRE_PRIORITY_RUNECHAT 410
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

//SSticker.current_state values
/// Game is loading
#define GAME_STATE_STARTUP 0
/// Game is loaded and in pregame lobby
#define GAME_STATE_PREGAME 1
/// Game is attempting to start the round
#define GAME_STATE_SETTING_UP 2
/// Game has round in progress
#define GAME_STATE_PLAYING 3
/// Game has round finished
#define GAME_STATE_FINISHED 4

/**
	Create a new timer and add it to the queue.
	* Arguments:
	* * callback the callback to call on timer finish
	* * wait deciseconds to run the timer for
	* * flags flags for this timer, see: code\__DEFINES\subsystems.dm
	* * timer_subsystem the subsystem to insert this timer into
*/
#define addtimer(args...) _addtimer(args, file = __FILE__, line = __LINE__)

// Air subsystem subtasks
#define SSAIR_PIPENETS 1
#define SSAIR_ATMOSMACHINERY 2
#define SSAIR_ACTIVETURFS 3
#define SSAIR_HOTSPOTS 4
#define SSAIR_EXCITEDGROUPS 5
#define SSAIR_HIGHPRESSURE 6
#define SSAIR_SUPERCONDUCTIVITY 7
#define SSAIR_PROCESS_ATOMS 8

// Pipeline rebuild helper defines, these suck but it'll do for now //Fools you actually merged it
#define SSAIR_REBUILD_PIPELINE 1
#define SSAIR_REBUILD_QUEUE 2

// Explosion Subsystem subtasks
#define SSEXPLOSIONS_MOVABLES 1
#define SSEXPLOSIONS_TURFS 2
#define SSEXPLOSIONS_THROWS 3

// Wardrobe subsystem tasks
#define SSWARDROBE_STOCK 1
#define SSWARDROBE_INSPECT 2

// Wardrobe cache metadata indexes
#define WARDROBE_CACHE_COUNT 1
#define WARDROBE_CACHE_LAST_INSPECT 2
#define WARDROBE_CACHE_CALL_INSERT 3
#define WARDROBE_CACHE_CALL_REMOVAL 4

// Wardrobe preloaded stock indexes
#define WARDROBE_STOCK_CONTENTS 1
#define WARDROBE_STOCK_CALL_INSERT 2
#define WARDROBE_STOCK_CALL_REMOVAL 3

// Wardrobe callback master list indexes
#define WARDROBE_CALLBACK_INSERT 1
#define WARDROBE_CALLBACK_REMOVE 2

// Subsystem delta times or tickrates, in seconds. I.e, how many seconds in between each process() call for objects being processed by that subsystem.
// Only use these defines if you want to access some other objects processing delta_time, otherwise use the delta_time that is sent as a parameter to process()
#define SSFLUIDS_DT (SSplumbing.wait/10)
#define SSMACHINES_DT (SSmachines.wait/10)
#define SSMOBS_DT (SSmobs.wait/10)
#define SSOBJ_DT (SSobj.wait/10)

/// The timer key used to know how long subsystem initialization takes
#define SS_INIT_TIMER_KEY "ss_init"

// Vote subsystem counting methods
/// First past the post. One selection per person, and the selection with the most votes wins.
#define VOTE_COUNT_METHOD_SINGLE 1
/// Approval voting. Any number of selections per person, and the selection with the most votes wins.
#define VOTE_COUNT_METHOD_MULTI 2

#define COMPILE_OVERLAYS(A) \
	do {\
		var/list/ad = A.add_overlays;\
		var/list/rm = A.remove_overlays;\
		var/list/po = A.priority_overlays;\
		if(LAZYLEN(rm)){\
			A.overlays -= rm;\
			rm.Cut();\
		}\
		if(LAZYLEN(ad)){\
			A.overlays |= ad;\
			ad.Cut();\
		}\
		if(LAZYLEN(po)){\
			A.overlays |= po;\
		}\
		A.flags_1 &= ~OVERLAY_QUEUED;\
	} while (FALSE)
