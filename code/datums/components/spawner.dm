/datum/component/spawner
	var/mob_types = list(/mob/living/simple_animal/hostile/carp)
	var/spawn_time = 300 //30 seconds default
	var/list/spawned_mobs = list()
	var/spawn_delay = 0
	var/max_mobs = 5
	var/spawn_text = "emerges from"
	var/squad_spawn = FALSE
	var/list/faction = list("xenomorph")


/datum/component/spawner/Initialize(_mob_types, _spawn_time, _spawn_text, _max_mobs, _squad_spawn, _faction)
	. = ..()
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

/datum/component/spawner/proc/try_spawn_mob()
	var/atom/P = parent
	if(spawned_mobs.len >= max_mobs)
		return 0
	if(spawn_delay > world.time)
		return 0
	spawn_delay = world.time + spawn_time
	to_chat(world, "spawndelay is [spawn_delay]")
	if(squad_spawn == FALSE)
		var/chosen_mob_type = pick(mob_types)
		var/mob/living/L = new chosen_mob_type(P.loc)
		spawned_mobs += L
	else
		for(var/mob in mob_types)
			var/mob/living/L = new mob(P.loc)
			spawned_mobs += L
	//L.flags_1 |= (P.flags_1 & ADMIN_SPAWNED_1)
	//spawned_mobs += L
	//L.faction = src.faction
	//P.visible_message("<span class='danger'>[L] [spawn_text] [P].</span>")
