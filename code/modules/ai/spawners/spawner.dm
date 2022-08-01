/atom/movable/effect/ai_node/spawner
	name = "AI spawner node"
	invisibility = INVISIBILITY_OBSERVER
	///typepath or list of typepaths for the spawner to pick from
	var/spawntypes
	///Amount of types to spawn for each squad created
	var/spawnamount
	///Delay between squad spawns, dont set this to below SSspawning wait
	var/spawndelay = 4 SECONDS
	///Max amount of
	var/maxamount = 5
	///Whether we want to use the postspawn proc on the mobs created by the Spawner
	var/use_postspawn = FALSE


//Example implementation;
/atom/movable/effect/ai_node/spawner/Initialize()
	if(!spawntypes || !spawnamount)
		stack_trace("Invalid spawn parameters on AI spawn node, deleting")
		return INITIALIZE_HINT_QDEL
	if(spawndelay < SSspawning.wait)
		stack_trace("Spawndelay too low, deleting AI spawner node")
		return INITIALIZE_HINT_QDEL
	. = ..()
	SSspawning.registerspawner(src, spawndelay, spawntypes, maxamount, spawnamount, use_postspawn ? CALLBACK(src, .proc/postspawn) : null)

///This proc runs on the created mobs if use_postspawn is enabled, use this to equip humans and such
/atom/movable/effect/ai_node/spawner/proc/postspawn(list/squad)
	return
