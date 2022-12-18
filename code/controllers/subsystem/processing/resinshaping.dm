#define QUICKBUILD_STRUCTURES_PER_XENO 300

SUBSYSTEM_DEF(resinshaping)
	name = "Resin Shaping"
	flags = SS_NO_FIRE | SS_NO_INIT
	var/list/xeno_builds_counter = list()
	var/total_structures_built = 0
	var/total_structures_refunded = 0

/datum/controller/subsystem/resinshaping/stat_entry()
	..("BUILT=[total_structures_built] REFUNDED=[total_structures_refunded]")

/datum/controller/subsystem/resinshaping/proc/get_building_points(mob/the_builder)
	var/player_key = "[the_builder.client?.ckey]"
	if(!player_key)
		return 0
	return QUICKBUILD_STRUCTURES_PER_XENO - xeno_builds_counter[player_key]

/datum/controller/subsystem/resinshaping/proc/increment_build_counter(mob/the_builder)
	var/player_key = "[the_builder.client?.ckey]"
	if(!player_key)
		return
	xeno_builds_counter[player_key]++
	total_structures_built++

/datum/controller/subsystem/resinshaping/proc/decrement_build_counter(mob/the_builder)
	var/player_key = "[the_builder.client?.ckey]"
	if(!player_key)
		return 0
	xeno_builds_counter[player_key]--
	total_structures_refunded++
	total_structures_built--


