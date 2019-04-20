GLOBAL_LIST_EMPTY(clients)							//all clients
GLOBAL_LIST_EMPTY(admins)							//all clients whom are admins
GLOBAL_PROTECT(admins)
GLOBAL_LIST_EMPTY(deadmins)							//all ckeys who have used the de-admin verb.

GLOBAL_LIST_EMPTY(directory)							//all ckeys with associated client
GLOBAL_LIST_EMPTY(stealthminID)						//reference list with IDs that store ckeys, for stealthmins

//Since it didn't really belong in any other category, I'm putting this here
//This is for procs to replace all the goddamn 'in world's that are chilling around the code

GLOBAL_LIST_EMPTY(player_list)				//all mobs **with clients attached**.
GLOBAL_LIST_EMPTY(mob_list)					//all mobs, including clientless
GLOBAL_LIST_EMPTY(mob_directory)			//mob_id -> mob
GLOBAL_LIST_EMPTY(observer_list)			//all /mob/dead/observer
GLOBAL_LIST_EMPTY(xeno_mob_list)			//all /mob/living/carbon/Xenomorph
GLOBAL_LIST_EMPTY(alive_xeno_list)			//as above except stat != DEAD
GLOBAL_LIST_EMPTY(dead_xeno_list)
GLOBAL_LIST_EMPTY(human_mob_list)			//all /mob/living/carbon/human including synths and species
GLOBAL_LIST_EMPTY(alive_human_list)			//as above except stat != DEAD
GLOBAL_LIST_EMPTY(dead_human_list)
GLOBAL_LIST_EMPTY(alive_mob_list)			//all alive mobs, including clientless. Excludes /mob/dead/new_player
GLOBAL_LIST_EMPTY(suicided_mob_list)		//contains a list of all mobs that suicided, including their associated ghosts.
GLOBAL_LIST_EMPTY(cryoed_mob_list)			//Used for logging people entering cryosleep
GLOBAL_LIST_EMPTY(drones_list)
GLOBAL_LIST_EMPTY(dead_mob_list)			//all dead mobs, including clientless. Excludes /mob/dead/new_player
GLOBAL_LIST_EMPTY(joined_player_list)		//all clients that have joined the game at round-start or as a latejoin.
GLOBAL_LIST_EMPTY(silicon_mobs)				//all silicon mobs
GLOBAL_LIST_EMPTY(mob_living_list)				//all instances of /mob/living and subtypes
GLOBAL_LIST_EMPTY(carbon_list)				//all instances of /mob/living/carbon and subtypes, notably does not contain brains or simple animals
GLOBAL_LIST_EMPTY(offered_mob_list)				//all /mobs offered by admins
GLOBAL_LIST_EMPTY(ai_list)
GLOBAL_LIST_EMPTY(available_ai_shells)
GLOBAL_LIST_INIT(simple_animals, list(list(),list(),list(),list())) // One for each AI_* status define
GLOBAL_LIST_EMPTY(spidermobs)				//all sentient spider mobs
GLOBAL_LIST_EMPTY(bots_list)
GLOBAL_LIST_EMPTY(living_cameras)
GLOBAL_LIST_EMPTY(aiEyes)

GLOBAL_LIST_EMPTY(language_datum_instances)
GLOBAL_LIST_EMPTY(all_languages)

GLOBAL_LIST_EMPTY(all_species)
GLOBAL_LIST_EMPTY(language_keys)	//table of say codes for all languages

GLOBAL_LIST_EMPTY(xeno_caste_datums)

GLOBAL_LIST_EMPTY(sentient_disease_instances)

GLOBAL_LIST_EMPTY(latejoin_ai_cores)

GLOBAL_LIST_EMPTY(mob_config_movespeed_type_lookup)

GLOBAL_LIST_EMPTY(hive_datums) // init by makeDatumRefLists()

/proc/update_config_movespeed_type_lookup(update_mobs = TRUE)
	return
/*
	var/list/mob_types = list()
	var/list/entry_value = CONFIG_GET(keyed_list/multiplicative_movespeed)
	for(var/path in entry_value)
		var/value = entry_value[path]
		if(!value)
			continue
		for(var/subpath in typesof(path))
			mob_types[subpath] = value
	GLOB.mob_config_movespeed_type_lookup = mob_types
	if(update_mobs)
		update_mob_config_movespeeds()
*/

/proc/update_mob_config_movespeeds()
	return
/*
	for(var/i in GLOB.mob_list)
		var/mob/M = i
		M.update_config_movespeed()
*/