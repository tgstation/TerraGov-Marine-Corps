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
GLOBAL_LIST_EMPTY(new_player_list)			//all /mob/new_player
GLOBAL_LIST_EMPTY(ready_players)			//all /mob/new_player that are (ready == TRUE)
GLOBAL_LIST_EMPTY(observer_list)			//all /mob/dead/observer
GLOBAL_LIST_EMPTY(xeno_mob_list)			//all /mob/living/carbon/xenomorph
GLOBAL_LIST_EMPTY(alive_xeno_list)			//as above except stat != DEAD
GLOBAL_LIST_EMPTY(alive_xeno_list_hive)		//living xenos by hive
GLOBAL_LIST_EMPTY(dead_xeno_list)
GLOBAL_LIST_EMPTY(human_mob_list)			//all /mob/living/carbon/human including synths and species
GLOBAL_LIST_EMPTY(alive_human_list)			//as above except stat != DEAD
GLOBAL_LIST_EMPTY(alive_human_list_faction) //as above but categorized by faction
GLOBAL_LIST_EMPTY(dead_human_list)
GLOBAL_LIST_EMPTY(cryoed_mob_list)			//Used for logging people entering cryosleep
GLOBAL_LIST_EMPTY(dead_mob_list)			//all dead mobs, including clientless. Excludes /mob/new_player
GLOBAL_LIST_EMPTY(joined_player_list)		//all clients that have joined the game at round-start or as a latejoin.
GLOBAL_LIST_EMPTY(mob_living_list)				//all instances of /mob/living and subtypes
GLOBAL_LIST_EMPTY(alive_living_list)		//all alive /mob/living, including clientless.
GLOBAL_LIST_EMPTY(offered_mob_list)				//all /mobs offered by admins
GLOBAL_LIST_EMPTY(ai_list)
GLOBAL_LIST_INIT(simple_animals, list(list(),list(),list(),list())) // One for each AI_* status define
GLOBAL_LIST_EMPTY(living_cameras)
GLOBAL_LIST_EMPTY(aiEyes)
GLOBAL_LIST_EMPTY(humans_by_zlevel)			//z level /list/list of alive humans
GLOBAL_LIST_EMPTY(observers_by_zlevel)

GLOBAL_LIST_EMPTY(mob_config_movespeed_type_lookup)

GLOBAL_LIST_EMPTY(real_names_joined)

GLOBAL_LIST_EMPTY(language_datum_instances)
GLOBAL_LIST_EMPTY(all_languages)

GLOBAL_LIST_EMPTY(all_species)
GLOBAL_LIST_EMPTY(roundstart_species)

GLOBAL_LIST_EMPTY_TYPED(xeno_caste_datums, /list/datum/xeno_caste)
GLOBAL_LIST_INIT(all_xeno_types, list(
	/mob/living/carbon/xenomorph/runner,
	/mob/living/carbon/xenomorph/runner/normal,
	/mob/living/carbon/xenomorph/runner/primordial,
	/mob/living/carbon/xenomorph/drone,
	/mob/living/carbon/xenomorph/drone/normal,
	/mob/living/carbon/xenomorph/drone/primordial,
	/mob/living/carbon/xenomorph/sentinel,
	/mob/living/carbon/xenomorph/sentinel/normal,
	/mob/living/carbon/xenomorph/sentinel/primordial,
	/mob/living/carbon/xenomorph/defender,
	/mob/living/carbon/xenomorph/defender/normal,
	/mob/living/carbon/xenomorph/defender/primordial,
	/mob/living/carbon/xenomorph/gorger,
	/mob/living/carbon/xenomorph/gorger/normal,
	/mob/living/carbon/xenomorph/gorger/primordial,
	/mob/living/carbon/xenomorph/hunter,
	/mob/living/carbon/xenomorph/hunter/normal,
	/mob/living/carbon/xenomorph/hunter/primordial,
	/mob/living/carbon/xenomorph/warrior,
	/mob/living/carbon/xenomorph/warrior/normal,
	/mob/living/carbon/xenomorph/warrior/primordial,
	/mob/living/carbon/xenomorph/spitter,
	/mob/living/carbon/xenomorph/spitter/normal,
	/mob/living/carbon/xenomorph/spitter/primordial,
	/mob/living/carbon/xenomorph/hivelord,
	/mob/living/carbon/xenomorph/hivelord/normal,
	/mob/living/carbon/xenomorph/hivelord/primordial,
	/mob/living/carbon/xenomorph/carrier,
	/mob/living/carbon/xenomorph/carrier/normal,
	/mob/living/carbon/xenomorph/carrier/primordial,
	/mob/living/carbon/xenomorph/bull,
	/mob/living/carbon/xenomorph/bull/normal,
	/mob/living/carbon/xenomorph/bull/primordial,
	/mob/living/carbon/xenomorph/queen,
	/mob/living/carbon/xenomorph/queen/normal,
	/mob/living/carbon/xenomorph/queen/primordial,
	/mob/living/carbon/xenomorph/king,
	/mob/living/carbon/xenomorph/king/normal,
	/mob/living/carbon/xenomorph/king/primordial,
	/mob/living/carbon/xenomorph/wraith,
	/mob/living/carbon/xenomorph/wraith/normal,
	/mob/living/carbon/xenomorph/wraith/primordial,
	/mob/living/carbon/xenomorph/ravager,
	/mob/living/carbon/xenomorph/ravager/normal,
	/mob/living/carbon/xenomorph/ravager/primordial,
	/mob/living/carbon/xenomorph/praetorian,
	/mob/living/carbon/xenomorph/praetorian/normal,
	/mob/living/carbon/xenomorph/praetorian/primordial,
	/mob/living/carbon/xenomorph/boiler,
	/mob/living/carbon/xenomorph/boiler/normal,
	/mob/living/carbon/xenomorph/boiler/primordial,
	/mob/living/carbon/xenomorph/defiler,
	/mob/living/carbon/xenomorph/defiler/normal,
	/mob/living/carbon/xenomorph/defiler/primordial,
	/mob/living/carbon/xenomorph/crusher,
	/mob/living/carbon/xenomorph/crusher/normal,
	/mob/living/carbon/xenomorph/crusher/primordial,
	/mob/living/carbon/xenomorph/widow,
	/mob/living/carbon/xenomorph/widow/normal,
	/mob/living/carbon/xenomorph/widow/primordial,
	/mob/living/carbon/xenomorph/shrike,
	/mob/living/carbon/xenomorph/shrike/normal,
	/mob/living/carbon/xenomorph/shrike/primordial,
	/mob/living/carbon/xenomorph/warlock,
	/mob/living/carbon/xenomorph/warlock/normal,
	/mob/living/carbon/xenomorph/warlock/primordial,
	/mob/living/carbon/xenomorph/beetle,
	/mob/living/carbon/xenomorph/mantis,
	/mob/living/carbon/xenomorph/scorpion,
	/mob/living/carbon/xenomorph/spiderling,
	))
GLOBAL_LIST_INIT(xeno_types_tier_one, list(/mob/living/carbon/xenomorph/runner, /mob/living/carbon/xenomorph/drone, /mob/living/carbon/xenomorph/sentinel, /mob/living/carbon/xenomorph/defender))
GLOBAL_LIST_INIT(xeno_types_tier_two, list(/mob/living/carbon/xenomorph/hunter, /mob/living/carbon/xenomorph/warrior, /mob/living/carbon/xenomorph/spitter, /mob/living/carbon/xenomorph/hivelord, /mob/living/carbon/xenomorph/carrier, /mob/living/carbon/xenomorph/bull, /mob/living/carbon/xenomorph/wraith))
GLOBAL_LIST_INIT(xeno_types_tier_three, list(/mob/living/carbon/xenomorph/gorger, /mob/living/carbon/xenomorph/widow, /mob/living/carbon/xenomorph/ravager, /mob/living/carbon/xenomorph/praetorian, /mob/living/carbon/xenomorph/boiler, /mob/living/carbon/xenomorph/defiler, /mob/living/carbon/xenomorph/crusher, /mob/living/carbon/xenomorph/shrike))

GLOBAL_LIST_EMPTY_TYPED(hive_datums, /datum/hive_status) // init by make_datum_references_lists()

///Contains static data passed to all hive status UI.
GLOBAL_LIST_EMPTY(hive_ui_static_data) // init by make_datum_references_lists()
///Returns the index of the corresponding static caste data given caste typepath.
GLOBAL_LIST_EMPTY(hive_ui_caste_index)

/proc/update_config_movespeed_type_lookup(update_mobs = TRUE)
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

/proc/update_mob_config_movespeeds()
	for(var/i in GLOB.mob_list)
		var/mob/M = i
		M.update_config_movespeed()
