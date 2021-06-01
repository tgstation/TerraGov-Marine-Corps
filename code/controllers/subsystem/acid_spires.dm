/**
 * Handles spawning and setting up acid spires
 */

SUBSYSTEM_DEF(acid_spires)
	name = "Acid spires"
	init_order = INIT_ORDER_ACID_SPIRES
	wait = 1 MINUTES
	///Amount of acid spires spawned at round-start
	var/acid_spire_spawn_amount = 2
	///Amount of acid that the system currently has
	var/stored_acid_amount = 100
	///Production strength of the acid spires network
	var/production_rate = 0
	///List of structures that tick when the system ticks
	var/list/connected_structures = list()

/datum/controller/subsystem/acid_spires/Initialize()
	for(var/obj/effect/landmark/acid_spire_spawner/spawner AS in shuffle(GLOB.acid_spire_landmarks_list))
		spawner.spawn_spire()
		acid_spire_spawn_amount--
		if(acid_spire_spawn_amount == 0)
			break

	return ..()

/datum/controller/subsystem/acid_spires/fire(resumed = 0)
	calculate_production_rate()
	stored_acid_amount += production_rate
	for(var/obj/structure/xeno/checked_structure AS in connected_structures)
		if(!checked_structure.on_acid_spires_tick())
			checked_structure.disconnect_from_acid_spire()

///Calculates the rate at which the system produces acid
/datum/controller/subsystem/acid_spires/proc/calculate_production_rate()
	production_rate = 0
	for(var/obj/structure/xeno/resin/acid_spire/checked_spire AS in GLOB.acid_spires)
		production_rate += checked_spire.production_strength()

///returns the acid available for use
/datum/controller/subsystem/acid_spires/proc/use_acid(use_amount)
	if(stored_acid_amount < use_amount)
		return FALSE
	stored_acid_amount -= use_amount
	return TRUE

///returns the acid available for use
/datum/controller/subsystem/acid_spires/proc/stored_acid()
	return stored_acid_amount
