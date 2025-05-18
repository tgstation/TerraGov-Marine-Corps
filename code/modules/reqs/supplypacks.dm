//SUPPLY PACKS//SUPPLY PACKS
//NOTE: only secure crate types use the access var (and are lockable)
//NOTE: Don't add living things to crates, that's bad, it will break the shuttle.
//NOTE: Do NOT set the price of any crates below 7 points. Doing so allows infinite points.

/datum/supply_packs
	var/name
	var/notes
	var/list/contains = list()
	var/cost
	var/obj/containertype
	var/access
	var/group
	///Randomly picks X of items out of the contains list instead of using all.
	var/randomised_num_contained = 0
	///If this supply pack should be buyable in HvH gamemode
	var/available_against_xeno_only = FALSE

/datum/supply_packs/proc/generate(atom/movable/location)
	for(var/i in contains)
		var/atom/movable/AM = i
		new AM(location)

