
#define MAXIMUM_DEFAULT_SPAWN 120

SUBSYSTEM_DEF(spawning)
	name = "Spawning"
	priority = FIRE_PRIORITY_SPAWNING
	flags = SS_NO_INIT
	wait = 40
	///Maximum amount of spawnable mobs
	var/mobcap = MAXIMUM_DEFAULT_SPAWN
	///total number of spawned mobs
	var/totalspawned = 0
	///Assoc list of spawners and their assosicated data
	var/list/datum/spawnerdata/spawnerdata = list()
	///Assoc list [mob] = removalcb
	var/list/datum/callback/callbacks_by_mob = list()

/datum/controller/subsystem/spawning/Recover()
	spawnerdata = SSspawning.spawnerdata
	callbacks_by_mob = SSspawning.callbacks_by_mob

///Admin proc to unregister and reregister AI node spawners for example for varedits on WO
/datum/controller/subsystem/spawning/proc/reset_ai()
	for(var/obj/effect/ai_node/spawner/spawner AS in spawnerdata)
		unregisterspawner(spawner)
		registerspawner(spawner, spawner.spawndelay, spawner.spawntypes, spawner.maxamount, spawner.spawnamount, spawner.use_postspawn ? CALLBACK(spawner, /obj/effect/ai_node/spawner.proc/postspawn) : null)


/**
 * Registers an atom with the subsystem
 * Arguments:
 * * spawner: atom to be registered
 * * delaytime: time in byond ticks between respawns dont make this lower than SS wait or perish
 * * spawntypes: can be both a list as well as a specific type for the spawner to spawn
 * * postspawn: Callback to be invoked on the spawned squad, use for equipping and such
 */
/datum/controller/subsystem/spawning/proc/registerspawner(atom/spawner, delaytime = 30 SECONDS, spawntypes, maxmobs = 10, spawnamount = 1, datum/callback/postspawn)
	spawnerdata[spawner] = new /datum/spawnerdata(delaytime/wait, spawntypes, maxmobs, spawnamount, postspawn)
	RegisterSignal(spawner, COMSIG_PARENT_QDELETING, .proc/unregisterspawner)

/**
 * Unregisters an atom with the subsystem
 * Arguments:
 * * spawner: atom to be unregistered
 */
/datum/controller/subsystem/spawning/proc/unregisterspawner(atom/spawner)
	SIGNAL_HANDLER
	callbacks_by_mob -= spawnerdata[spawner].spawnedmobs
	spawnerdata -= spawner
	UnregisterSignal(spawner, COMSIG_PARENT_QDELETING)


///Essentially a wrapper for accessing a dying/delting mobs callback to remove it
/datum/controller/subsystem/spawning/proc/remove_mob(mob/source)
	SIGNAL_HANDLER
	callbacks_by_mob[source].Invoke()
	UnregisterSignal(source, list(COMSIG_PARENT_QDELETING, COMSIG_MOB_DEATH))

/**
 * Removes a mob from a spawners mobs spawned list
 * Arguments:
 * * remover: The mob that died/whatever to decrement the amount
 * * spawner: atom that spawned the mob that died
 */
/datum/controller/subsystem/spawning/proc/decrement_spawnedmobs(mob/remover, atom/spawner)
	spawnerdata[spawner].spawnedmobs -= remover
	callbacks_by_mob -= remover
	totalspawned--

/datum/controller/subsystem/spawning/fire(resumed)
	if(totalspawned >= mobcap)
		return

	for(var/spawner in spawnerdata)
		if(++spawnerdata[spawner].fire_increment <= spawnerdata[spawner].required_increment)
			continue
		spawnerdata[spawner].fire_increment = 0
		var/turf/spawnpoint = get_turf(spawner)
		var/list/squad = list()
		for(var/b = 0 to spawnerdata[spawner].spawnamount)
			if(length(spawnerdata[spawner].spawnedmobs) >= spawnerdata[spawner].max_allowed_mobs)
				break
			var/spawntype = pick(spawnerdata[spawner].spawntypes)
			var/mob/newmob = new spawntype(spawnpoint)

			var/datum/callback/deathcb = CALLBACK(src, .proc/decrement_spawnedmobs, newmob, spawner)
			callbacks_by_mob[newmob] = deathcb
			RegisterSignal(newmob, list(COMSIG_PARENT_QDELETING, COMSIG_MOB_DEATH), .proc/remove_mob)
			spawnerdata[spawner].spawnedmobs += newmob
			squad += newmob
			totalspawned++
		spawnerdata[spawner].post_spawn_cb?.Invoke(squad)
		if(TICK_CHECK)
			return

/// Holder datum for various data relating to individual spawners
/datum/spawnerdata
	///Fire incrementor
	var/fire_increment = 0
	///Required fire increment
	var/required_increment
	///Spawn types
	var/spawntypes
	///Spawn amount
	var/spawnamount
	///Max allowed mobs
	var/max_allowed_mobs
	///Spawned mobs
	var/list/spawnedmobs = list()
	///Post spawn callback
	var/datum/callback/post_spawn_cb

/datum/spawnerdata/New(increment, spawntypesarg, max, squadamount, datum/callback/postcb)
	required_increment = increment
	spawntypes = spawntypesarg
	max_allowed_mobs = max
	spawnamount = squadamount
	post_spawn_cb = postcb
