SUBSYSTEM_DEF(modularmapping)
	name = "Modularmapping"
	init_order = INIT_ORDER_MODULARMAPPING
	flags = SS_NO_FIRE
	var/list/atom/movable/effect/spawner/modularmap/markers = list()

/datum/controller/subsystem/modularmapping/Initialize(start_timeofday)
	for(var/atom/movable/effect/spawner/modularmap/map AS in markers)
		map.load_modularmap()
	markers = null
	return ..()
