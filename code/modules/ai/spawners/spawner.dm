/obj/effect/ai_node/spawner
	name = "AI spawner node"
	invisibility = INVISIBILITY_OBSERVER
	///typepath or list of typepaths for the spawner to pick from, include weights of spawn_types for proper picking out
	var/list/spawntypes
	///Amount of types to spawn for each squad created
	var/spawnamount
	///Delay between squad spawns, dont set this to below SSspawning wait
	var/spawndelay = 4 SECONDS
	///Max amount of
	var/maxamount = 5
	///Whether we want to use the post_spawn proc on the mobs created by the Spawner
	var/use_postspawn = FALSE
	///List of signals on which we remove mob from spawned_mobs
	var/mob_decrement_signals = list(COMSIG_QDELETING, COMSIG_MOB_DEATH)

//Example implementation;
/obj/effect/ai_node/spawner/Initialize(mapload)
	if(!spawntypes || !spawnamount)
		stack_trace("Invalid spawn parameters on AI spawn node, deleting")
		return INITIALIZE_HINT_QDEL
	if(spawndelay < SSspawning.wait)
		stack_trace("spawn_delay too low, deleting AI spawner node")
		return INITIALIZE_HINT_QDEL
	. = ..()
	SSspawning.registerspawner(src, spawndelay, spawntypes, maxamount, spawnamount, use_postspawn ? CALLBACK(src, PROC_REF(post_spawn)) : null, mob_decrement_signals)

///This proc runs on the created mobs if use_post_spawn is enabled, use this to equip humans and such
/obj/effect/ai_node/spawner/proc/post_spawn(list/squad)
	return
