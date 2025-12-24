SUBSYSTEM_DEF(modularmapping)
	name = "Modular Mapping"
	dependencies = list(
		/datum/controller/subsystem/atoms,
	)
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
	require_area_resort() //adds all the modular map areas to the list
