GLOBAL_LIST_INIT(cardinals, list(NORTH, SOUTH, EAST, WEST))
GLOBAL_LIST_INIT(alldirs, list(NORTH, SOUTH, EAST, WEST, NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST))
GLOBAL_LIST_INIT(diagonals, list(NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST))

//Spawnpoints.
GLOBAL_LIST_EMPTY(latejoin)
GLOBAL_LIST_EMPTY(latejoinsom)
GLOBAL_LIST_EMPTY(latejoin_gateway)
GLOBAL_LIST_EMPTY(latejoin_cryo)

GLOBAL_LIST_EMPTY(landmarks_list)				//list of all landmarks created
GLOBAL_LIST_EMPTY(start_landmarks_list)			//list of all spawn points created
GLOBAL_LIST_EMPTY(corpse_landmarks_list)		//list of all corpse spawner
GLOBAL_LIST_EMPTY(valhalla_button_spawn_landmark) //list of the landmarks used to spawn mobs for the valhalla buttons

GLOBAL_LIST_EMPTY(spawns_by_job)			//2d array of /datum/job => list(turfs)

GLOBAL_LIST_EMPTY(landmarks_round_start)		//landmarks that require action at round start

GLOBAL_LIST_EMPTY(map_items)
GLOBAL_LIST_EMPTY(fog_blocker_locations)		//list of turfs marked by /obj/effect/landmark/lv624/fog_blocker
GLOBAL_LIST_EMPTY(xeno_spawn_protection_locations)
GLOBAL_LIST_EMPTY(fog_blockers)

GLOBAL_LIST_EMPTY(huntergames_primary_spawns)
GLOBAL_LIST_EMPTY(huntergames_secondary_spawns)


GLOBAL_LIST_EMPTY(newplayer_start)
GLOBAL_LIST_EMPTY(tdome1)
GLOBAL_LIST_EMPTY(tdome2)
GLOBAL_LIST_EMPTY(deathmatch)

GLOBAL_VAR_INIT(minidropship_start_loc, null)

//used by jump-to-area etc. Updated by area/updateName()
GLOBAL_LIST_EMPTY(sorted_areas)
/// An association from typepath to area instance. Only includes areas with `unique` set.
GLOBAL_LIST_EMPTY_TYPED(areas_by_type, /area)

GLOBAL_LIST_INIT(diagonal_smoothing_conversion, list(\
	"[NORTHEAST]" = N_NORTHEAST, "[NORTHWEST]" = N_NORTHWEST, "[SOUTHEAST]" = N_SOUTHEAST, "[SOUTHWEST]" = N_SOUTHWEST,\
	"[N_NORTHEAST]" = NORTHEAST, "[N_NORTHWEST]" = NORTHWEST, "[N_SOUTHEAST]" = SOUTHEAST, "[N_SOUTHWEST]" = SOUTHWEST))
