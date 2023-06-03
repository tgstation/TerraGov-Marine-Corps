SUBSYSTEM_DEF(modularmapping)
	name = "Modularmapping"
	init_order = INIT_ORDER_MODULARMAPPING
	flags = SS_NO_FIRE
	var/list/obj/effect/spawner/modularmap/markers = list()

/datum/controller/subsystem/modularmapping/Initialize()
	load_modular_maps()
	return SS_INIT_SUCCESS

///Loads any pending modular map files
/datum/controller/subsystem/modularmapping/proc/load_modular_maps()
	for(var/obj/effect/spawner/modularmap/map AS in markers)
		map.load_modularmap()
	markers.Cut()
	repopulate_sorted_areas() //adds all the modular map areas to the list
