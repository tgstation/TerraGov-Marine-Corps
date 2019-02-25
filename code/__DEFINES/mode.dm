//SSticker.current_state values
#define GAME_STATE_STARTUP		0
#define GAME_STATE_PREGAME		1
#define GAME_STATE_SETTING_UP	2
#define GAME_STATE_PLAYING		3
#define GAME_STATE_FINISHED		4


//=================================================
//Self destruct, nuke, and evacuation.
#define EVACUATION_TIME_LOCK 60 MINUTES
#define DISTRESS_TIME_LOCK 10 MINUTES
#define SHUTTLE_TIME_LOCK 10 MINUTES
#define SHUTTLE_LOCK_COOLDOWN 10 MINUTES
#define SHUTTLE_LOCK_TIME_LOCK 45 MINUTES
#define EVACUATION_AUTOMATIC_DEPARTURE 3 MINUTES //All pods automatically depart in 10 minutes, unless they are full or unable to launch for some reason.
#define EVACUATION_ESTIMATE_DEPARTURE ((evac_time + EVACUATION_AUTOMATIC_DEPARTURE - world.time) * 0.1)
#define EVACUATION_STATUS_STANDING_BY 0
#define EVACUATION_STATUS_INITIATING 1
#define EVACUATION_STATUS_IN_PROGRESS 2
#define EVACUATION_STATUS_COMPLETE 3

#define COOLDOWN_COMM_REQUEST 5 MINUTES
#define COOLDOWN_COMM_MESSAGE 1 MINUTES
#define COOLDOWN_COMM_CENTRAL 30 SECONDS

#define FOG_DELAY_INTERVAL	30 MINUTES

#define NUKE_EXPLOSION_INACTIVE 0
#define NUKE_EXPLOSION_ACTIVE	1
#define NUKE_EXPLOSION_IN_PROGRESS 2
#define NUKE_EXPLOSION_FINISHED 3

#define FLAGS_EVACUATION_DENY 1
#define FLAGS_SELF_DESTRUCT_DENY 2
//=================================================

#define MODE_INFESTATION		(1 << 0)
#define MODE_PREDATOR			(1 << 1)
#define MODE_NO_LATEJOIN		(1 << 2)
#define MODE_HAS_FINISHED		(1 << 3)
#define MODE_FOG_ACTIVATED 		(1 << 4)
#define MODE_INFECTION			(1 << 5)
#define MODE_HUMAN_ANTAGS		(1 << 6)

#define MODE_LANDMARK_RANDOM_ITEMS			(1 << 0)
#define MODE_LANDMARK_SPAWN_XENO_TUNNELS	(1 << 1)
#define MODE_LANDMARK_HELLHOUND_BLOCKER		(1 << 2)
#define MODE_LANDMARK_SPAWN_MAP_ITEM		(1 << 3)

//=================================================

#define LATEJOIN_LARVA_DISABLED 0