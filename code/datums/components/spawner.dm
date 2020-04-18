/datum/component/spawner
	///List of things we want to spawn at some point
	var/mob_types = list(/mob/living/simple_animal/hostile/carp)
	///How long we want it to be between spawns
	var/spawn_time = 15	//The SS fires once every 2 seconds so just 2* whatever this number is for spawn times in seconds
	///Keeps track of all our mobs
	var/list/spawned_mobs = list()
	///delay till a new mob spawns
	var/spawn_delay = 0
	///Cap to prevent a massive pile of mobs
	var/max_mobs = 5
	///In case players can see the spawning mob, say if we stick the component on a xeno
	var/spawn_text = "emerges from"
	///Whether all the contents of mob_types should be spawned at once or not
	var/squad_spawn = FALSE
	///What faction we want this mob to be a part of
	var/list/faction = list("xenomorph")


/datum/component/spawner/Initialize(_mob_types, _spawn_time, _spawn_text, _max_mobs, _squad_spawn, _faction)
	. = ..()	//Just in case
	if(_spawn_time)
		spawn_time = _spawn_time
	if(_mob_types)
		mob_types = _mob_types
	if(_spawn_text)
		spawn_text = _spawn_text
	if(_max_mobs)
		max_mobs = _max_mobs
	if(_squad_spawn)
		squad_spawn = _squad_spawn
	if(_faction)
		faction = _faction

	RegisterSignal(parent, list(COMSIG_PARENT_QDELETING), .proc/stop_spawning)
	START_PROCESSING(SSspawning, src)

/datum/component/spawner/process()
	try_spawn_mob()


/datum/component/spawner/proc/stop_spawning(force)
	STOP_PROCESSING(SSspawning, src)
	spawned_mobs = null

///Proc that checks whether we can spawn a mob and then spawns the mob in the specified fashion 
/datum/component/spawner/proc/try_spawn_mob()
	for(var/spawned in spawned_mobs)
		var/mob/tocheck = spawned
		if(QDELETED(tocheck))	//Check if our mob was deleted
			spawned_mobs -= tocheck	//and remove them if they were
	var/atom/P = parent
	if(spawned_mobs.len >= max_mobs)	//too many mobs
		return FALSE
	if(spawn_delay > world.time)	//Not time to spawn yet
		return FALSE
	spawn_delay = world.time + spawn_time
	if(!squad_spawn)	//for picking ONE mob to spawn

		var/chosen_mob_type = pick(mob_types)
		var/mob/living/L = new chosen_mob_type(P.loc)
		set_info(L,P)
		return

	for(var/mob in mob_types)	//Spawn the entire list
		if(spawned_mobs.len >= max_mobs)	//We've hit the mob limit, let's not spawn the rest of the list
			break
		var/mob/living/L = new mob(P.loc)
		set_info(L,P)


///Sets the post-spawn info for the mob
/datum/component/spawner/proc/set_info(mob/living/spawned, atom/parent)
	spawned_mobs += spawned
	if(faction)
		spawned.faction = faction
	parent.visible_message("<span class='danger'>[spawned] [spawn_text] [parent].</span>")
