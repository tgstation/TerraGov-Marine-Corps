//SSticker.current_state values
#define GAME_STATE_STARTUP		0
#define GAME_STATE_PREGAME		1
#define GAME_STATE_SETTING_UP	2
#define GAME_STATE_PLAYING		3
#define GAME_STATE_FINISHED		4


//SD and evac
#define NUKE_EXPLOSION_INACTIVE 0
#define NUKE_EXPLOSION_ACTIVE	1
#define NUKE_EXPLOSION_IN_PROGRESS 2
#define NUKE_EXPLOSION_FINISHED 3

#define SELF_DESTRUCT_ROD_STARTUP_TIME 20 MINUTES

#define SELF_DESTRUCT_MACHINE_INACTIVE 0
#define SELF_DESTRUCT_MACHINE_ACTIVE 1
#define SELF_DESTRUCT_MACHINE_ARMED 2

#define EVACUATION_STATUS_STANDING_BY 0
#define EVACUATION_STATUS_INITIATING 1
#define EVACUATION_STATUS_IN_PROGRESS 2
#define EVACUATION_STATUS_COMPLETE 3

#define EVACUATION_AUTOMATIC_DEPARTURE 3 MINUTES //All pods automatically depart in 10 minutes, unless they are full or unable to launch for some reason.
#define EVACUATION_ESTIMATE_DEPARTURE ((evac_time + EVACUATION_AUTOMATIC_DEPARTURE - world.time) * 0.1)
#define EVACUATION_POD_LAUNCH_COOLDOWN 5 SECONDS

#define FLAGS_EVACUATION_DENY 		(1<<0)
#define FLAGS_SELF_DESTRUCT_DENY 	(1<<1)
#define FLAGS_SDEVAC_TIMELOCK		(1<<2)


//Mode defines
#define MODE_INFESTATION		(1<<0)
#define MODE_NO_LATEJOIN		(1<<1)
#define MODE_HAS_FINISHED		(1<<2)
#define MODE_FOG_ACTIVATED 		(1<<3)
#define MODE_INFECTION			(1<<4)
#define MODE_HUMAN_ANTAGS		(1<<5)

#define MODE_LANDMARK_RANDOM_ITEMS			(1<<0)
#define MODE_LANDMARK_SPAWN_XENO_TUNNELS	(1<<1)
#define MODE_LANDMARK_SPAWN_MAP_ITEM		(1<<2)

#define MODE_INFESTATION_X_MAJOR		"Xenomorph Major Victory"
#define MODE_INFESTATION_M_MAJOR		"Marine Major Victory"
#define MODE_INFESTATION_X_MINOR		"Xenomorph Minor Victory"
#define MODE_INFESTATION_M_MINOR		"Marine Minor Victory"
#define MODE_INFESTATION_DRAW_DEATH		"DRAW: Mutual Annihilation"

#define MODE_BATTLEFIELD_NT_MAJOR		"NT PMC Major Success"
#define MODE_BATTLEFIELD_M_MAJOR		"Marine Major Success"
#define MODE_BATTLEFIELD_NT_MINOR		"NT PMC Minor Success"
#define MODE_BATTLEFIELD_M_MINOR		"Marine Minor Success"
#define MODE_BATTLEFIELD_DRAW_STALEMATE "DRAW: Stalemate"
#define MODE_BATTLEFIELD_DRAW_DEATH		"DRAW: My Friends Are Dead"

#define MODE_GENERIC_DRAW_NUKE			"DRAW: Nuclear Explosion"

#define SURVIVOR_WEAPONS list(\
				list(/obj/item/weapon/gun/smg/mp7, /obj/item/ammo_magazine/smg/mp7),\
				list(/obj/item/weapon/gun/shotgun/double/sawn, /obj/item/ammo_magazine/shotgun/flechette),\
				list(/obj/item/weapon/gun/smg/uzi, /obj/item/ammo_magazine/smg/uzi),\
				list(/obj/item/weapon/gun/smg/mp5, /obj/item/ammo_magazine/smg/mp5),\
				list(/obj/item/weapon/gun/rifle/m16, /obj/item/ammo_magazine/rifle/m16),\
				list(/obj/item/weapon/gun/shotgun/pump/bolt, /obj/item/ammo_magazine/rifle/bolt))


#define LATEJOIN_LARVA_DISABLED 0


//Balance defines
#define MARINE_GEAR_SCALING		30

#define MAX_TUNNELS_PER_MAP 	10

#define QUEEN_DEATH_COUNTDOWN 	15 MINUTES
#define QUEEN_DEATH_NOLARVA		5 MINUTES

#define FOG_DELAY_INTERVAL		30 MINUTES

#define EVACUATION_TIME_LOCK	30 MINUTES

#define DISTRESS_TIME_LOCK 		10 MINUTES

#define SHUTTLE_TIME_LOCK 		10 MINUTES
#define SHUTTLE_LOCK_COOLDOWN 	10 MINUTES
#define SHUTTLE_LOCK_TIME_LOCK 	45 MINUTES

#define COOLDOWN_COMM_REQUEST 	5 MINUTES
#define COOLDOWN_COMM_MESSAGE 	1 MINUTES
#define COOLDOWN_COMM_CENTRAL 	30 SECONDS

#define XENO_AFK_TIMER			5 MINUTES

#define DEATHTIME_CHECK(M) ((world.time - M.timeofdeath) > GLOB.respawntime) && check_other_rights(M.client, R_ADMIN, FALSE)
#define DEATHTIME_MESSAGE(M) to_chat(M, "<span class='warning'>You have been dead for [(world.time - M.timeofdeath) * 0.1] second\s.</span><br><span class='warning'>You must wait [GLOB.respawntime * 0.1] seconds before rejoining the game!</span>")