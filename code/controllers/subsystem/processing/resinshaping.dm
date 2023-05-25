

/// Controls how many quickbuilds each xenomorph gets.
#define QUICKBUILD_STRUCTURES_PER_XENO 600


SUBSYSTEM_DEF(resinshaping)
	name = "Resin Shaping"
	flags = SS_NO_FIRE
	/// A list used to count how many buildings were built by player ckey , counter[ckey] = [build_count]
	var/list/xeno_builds_counter = list()
	/// Counter for total structures built
	var/total_structures_built = 0
	/// Counter for total refunds of structures
	var/total_structures_refunded = 0
	/// Used to check wheter or not the subsystem is active , used for preventing refunds from early landings
	var/active = TRUE

/datum/controller/subsystem/resinshaping/stat_entry()
	..("BUILT=[total_structures_built] REFUNDED=[total_structures_refunded]")

/datum/controller/subsystem/resinshaping/proc/toggle_off()
	SIGNAL_HANDLER
	active = FALSE
	UnregisterSignal(SSdcs, list(COMSIG_GLOB_OPEN_SHUTTERS_EARLY, COMSIG_GLOB_OPEN_TIMED_SHUTTERS_LATE,COMSIG_GLOB_OPEN_TIMED_SHUTTERS_XENO_HIVEMIND,COMSIG_GLOB_TADPOLE_LAUNCHED,COMSIG_GLOB_DROPPOD_LANDED))

/datum/controller/subsystem/resinshaping/Initialize()
	RegisterSignal(SSdcs, list(COMSIG_GLOB_OPEN_SHUTTERS_EARLY, COMSIG_GLOB_OPEN_TIMED_SHUTTERS_LATE,COMSIG_GLOB_OPEN_TIMED_SHUTTERS_XENO_HIVEMIND,COMSIG_GLOB_TADPOLE_LAUNCHED,COMSIG_GLOB_DROPPOD_LANDED), PROC_REF(toggle_off))
	return SS_INIT_SUCCESS

/// Retrieves a mob's building points using their ckey. Only works for mobs with clients.
/datum/controller/subsystem/resinshaping/proc/get_building_points(mob/the_builder)
	var/player_key = "[the_builder.client?.ckey]"
	if(!player_key)
		return 0
	return QUICKBUILD_STRUCTURES_PER_XENO - xeno_builds_counter[player_key]

/// Increments a mob buildings count , using their ckey.
/datum/controller/subsystem/resinshaping/proc/increment_build_counter(mob/the_builder)
	var/player_key = "[the_builder.client?.ckey]"
	if(!player_key)
		return
	xeno_builds_counter[player_key]++
	total_structures_built++

/// Decrements a mob buildings count , using their ckey.
/datum/controller/subsystem/resinshaping/proc/decrement_build_counter(mob/the_builder)
	var/player_key = "[the_builder.client?.ckey]"
	if(!player_key)
		return 0
	xeno_builds_counter[player_key]--
	total_structures_refunded++
	total_structures_built--

/// Returns a TRUE if a structure should be refunded and instant deconstructed , or false if not
/datum/controller/subsystem/resinshaping/proc/should_refund(atom/structure, mob/the_demolisher)
	var/player_key = "[the_demolisher.client?.ckey]"
	// could be a AI mob thats demolishing without a player key.
	if(!player_key || !active)
		return FALSE
	if(istype(structure, /obj/alien/resin/sticky) && !istype(structure,/obj/alien/resin/sticky/thin))
		return TRUE
	if(istype(structure, /turf/closed/wall/resin))
		return TRUE
	if(istype(structure, /obj/structure/mineral_door/resin))
		return TRUE
	return FALSE


