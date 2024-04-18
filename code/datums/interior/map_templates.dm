/datum/map_template/interior
	name = "Base Interior Template"
	///just the prefix so we dont need to fill in the entire thing
	var/prefix = "_maps/interiors/"
	///filename without file type for the map
	var/filename

/datum/map_template/interior/New()
	mappath = "[prefix][filename].dmm"
	return ..()

/datum/map_template/interior/medium_tank
	name = "medium tank interior template"
	filename = "tank"

/datum/map_template/interior/transport
	name = "transport apc interior template"
	filename = "apc_transport"

/datum/map_template/interior/medical
	name = "medical apc interior template"
	filename = "apc_medical"
