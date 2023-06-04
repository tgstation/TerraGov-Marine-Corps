/// The amount of quickbuilds given back per xeno spawned. Measured as a percentage of the starting amount.
#define QUICKBUILDS_PER_XENO 0.1


SUBSYSTEM_DEF(resinshaping)
	name = "Resin Shaping"
	flags = SS_NO_FIRE
	/// Counter for remaining quickbuilds, as long as this is above 0 building is instant.
	var/remaining_quickbuilds = 0
	/// Used to check wheter or not the subsystem is active , used for preventing refunds from early landings
	var/active = TRUE

/datum/controller/subsystem/resinshaping/stat_entry()
	..("REMAINING=[remaining_quickbuilds]")

/datum/controller/subsystem/resinshaping/proc/toggle_off()
	SIGNAL_HANDLER
	active = FALSE
	UnregisterSignal(SSdcs, list(COMSIG_GLOB_OPEN_SHUTTERS_EARLY, COMSIG_GLOB_OPEN_TIMED_SHUTTERS_LATE,COMSIG_GLOB_OPEN_TIMED_SHUTTERS_XENO_HIVEMIND,COMSIG_GLOB_TADPOLE_LAUNCHED,COMSIG_GLOB_DROPPOD_LANDED))

/datum/controller/subsystem/resinshaping/Initialize()
	RegisterSignal(SSdcs, list(COMSIG_GLOB_OPEN_SHUTTERS_EARLY, COMSIG_GLOB_OPEN_TIMED_SHUTTERS_LATE,COMSIG_GLOB_OPEN_TIMED_SHUTTERS_XENO_HIVEMIND,COMSIG_GLOB_TADPOLE_LAUNCHED,COMSIG_GLOB_DROPPOD_LANDED), PROC_REF(toggle_off))
	RegisterSignal(SSdcs, )
	return SS_INIT_SUCCESS

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


