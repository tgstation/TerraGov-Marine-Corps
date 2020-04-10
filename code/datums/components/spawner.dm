/datum/component/spawner
	///List of things we want to spawn at some point
	var/mob_types = list(/mob/living/simple_animal/hostile/carp)
	///How long we want it to be between spawns
	var/spawn_time = 300 //30 seconds default
	///Keeps track of all our mobs
	var/list/spawned_mobs = list()
	///delay till a new mob spawns
	var/spawn_delay = 0
	///Cap to prevent a massive pile of mobs
	var/max_mobs = 5
	///In case players can see the spawning mob
	var/spawn_text = "emerges from"
	///Whether all the contents of mob_types should be spawned at once or not
	var/squad_spawn = FALSE
	///What faction we want this mob to be a part of
	var/list/faction = list("xenomorph")


/datum/component/spawner/Initialize(_mob_types, _spawn_time, _spawn_text, _max_mobs, _squad_spawn, _faction)
	. = ..()	//Just in case
	if(_spawn_time)
		spawn_time=_spawn_time
	if(_mob_types)
		mob_types=_mob_types
	if(_spawn_text)
		spawn_text=_spawn_text
	if(_max_mobs)
		max_mobs=_max_mobs
	if(_squad_spawn)
		squad_spawn = _squad_spawn
	if(_faction)
		faction=_faction

	RegisterSignal(parent, list(COMSIG_PARENT_QDELETING), .proc/stop_spawning)
	START_PROCESSING(SSprocessing, src)
	to_chat(world, "poststartprocess")

/datum/component/spawner/process()
	to_chat(world, "process")
	try_spawn_mob()


/datum/component/spawner/proc/stop_spawning(force)
	STOP_PROCESSING(SSprocessing, src)
	to_chat(world, "stopped processing")
	spawned_mobs = null

///Lets start trying to spawn the mob
/datum/component/spawner/proc/try_spawn_mob()
	var/atom/P = parent
	if(spawned_mobs.len >= max_mobs)	//too many mobs
		return 0
	if(spawn_delay > world.time)	//Not time to spawn yet
		return 0
	spawn_delay = world.time + spawn_time
	to_chat(world, "spawndelay is [spawn_delay]")
	if(squad_spawn == FALSE)	//for picking ONE mob to spawn
		var/chosen_mob_type = pick(mob_types)
		var/mob/living/L = new chosen_mob_type(P.loc)
		spawned_mobs += L
	else
		for(var/mob in mob_types)	//Spawn the entire list
			var/mob/living/L = new mob(P.loc)
			spawned_mobs += L
	//spawned_mobs += L
	//L.faction = src.faction
	//P.visible_message("<span class='danger'>[L] [spawn_text] [P].</span>")
