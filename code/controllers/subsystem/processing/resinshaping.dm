#define QUICKBUILD_STRUCTURES_PER_XENO 600

SUBSYSTEM_DEF(resinshaping)
	name = "Resin Shaping"
	flags = SS_NO_FIRE | SS_NO_INIT
	var/list/xeno_builds_counter = list()
	var/total_structures_built = 0
	var/total_structures_refunded = 0

/datum/controller/subsystem/resinshaping/stat_entry()
	..("BUILT=[total_structures_built] REFUNDED=[total_structures_refunded]")

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


