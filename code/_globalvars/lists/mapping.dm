GLOBAL_LIST_INIT(cardinals, list(NORTH, SOUTH, EAST, WEST))
GLOBAL_LIST_INIT(alldirs, list(NORTH, SOUTH, EAST, WEST, NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST))
GLOBAL_LIST_INIT(diagonals, list(NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST))

//Spawnpoints.
GLOBAL_LIST_EMPTY(latejoin)
GLOBAL_LIST_EMPTY(latejoin_gateway)
GLOBAL_LIST_EMPTY(latejoin_cryo)

GLOBAL_VAR(supply_elevator)
GLOBAL_LIST_EMPTY(shuttle_locations)			//list of all /obj/effect/landmark/shuttle_loc

GLOBAL_LIST_EMPTY(landmarks_list)				//list of all landmarks created
GLOBAL_LIST_EMPTY(start_landmarks_list)			//list of all spawn points created

GLOBAL_LIST_EMPTY(marine_spawns_by_job)			//2d array of /datum/job => list(turfs)

GLOBAL_LIST_EMPTY(distress_spawns_by_name)

GLOBAL_LIST_EMPTY(landmarks_round_start)		//landmarks that require action at round start

GLOBAL_LIST_EMPTY(xeno_tunnel_landmarks)		//list of turfs marked by /obj/effect/landmark/xeno_tunnel
GLOBAL_LIST_EMPTY(map_items)
GLOBAL_LIST_EMPTY(fog_blocker_locations)		//list of turfs marked by /obj/effect/landmark/lv624/fog_blocker
GLOBAL_LIST_EMPTY(fog_blockers)

GLOBAL_VAR(map_tag)

GLOBAL_LIST_EMPTY(huntergames_primary_spawns)
GLOBAL_LIST_EMPTY(huntergames_secondary_spawns)

GLOBAL_LIST_EMPTY(department_security_spawns)	//list of all department security spawns
GLOBAL_LIST_EMPTY(generic_event_spawns)			//list of all spawns for events
GLOBAL_LIST_EMPTY(jobspawn_overrides)					//These will take precedence over normal spawnpoints if created.

GLOBAL_LIST_EMPTY(wizardstart)
GLOBAL_LIST_EMPTY(nukeop_start)
GLOBAL_LIST_EMPTY(nukeop_leader_start)
GLOBAL_LIST_EMPTY(newplayer_start)
GLOBAL_LIST_EMPTY(prisonwarp)	//prisoners go to these
GLOBAL_LIST_EMPTY(xeno_spawn)//Aliens spawn at these.
GLOBAL_LIST_EMPTY(surv_spawn)
GLOBAL_LIST_EMPTY(pred_spawn)
GLOBAL_LIST_EMPTY(pred_elder_spawn)
GLOBAL_LIST_EMPTY(yautja_teleport_loc) //Yautja teleporter target location.
GLOBAL_LIST_EMPTY(tdome1)
GLOBAL_LIST_EMPTY(tdome2)
GLOBAL_LIST_EMPTY(deathmatch)
GLOBAL_LIST_EMPTY(prisonwarped)	//list of players already warped
GLOBAL_LIST_EMPTY(secequipment)
GLOBAL_LIST_EMPTY(deathsquadspawn)
GLOBAL_LIST_EMPTY(emergencyresponseteamspawn)
GLOBAL_LIST_EMPTY(servant_spawns) //Servants of Ratvar spawn here
GLOBAL_LIST_EMPTY(city_of_cogs_spawns) //Anyone entering the City of Cogs spawns here
GLOBAL_LIST_EMPTY(ruin_landmarks)

	//away missions
GLOBAL_LIST_EMPTY(awaydestinations)	//a list of landmarks that the warpgate can take you to
GLOBAL_LIST_EMPTY(vr_spawnpoints)

	//used by jump-to-area etc. Updated by area/updateName()
GLOBAL_LIST_EMPTY(sortedAreas)
/// An association from typepath to area instance. Only includes areas with `unique` set.
GLOBAL_LIST_EMPTY(areas_by_type)

GLOBAL_LIST_EMPTY(all_abstract_markers)
