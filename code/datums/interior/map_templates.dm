/datum/map_template/interior
	name = "Base Interior Template"
	var/prefix = "_maps/interiors/"
	var/filename

/datum/map_template/interior/New()
	mappath = "[prefix][filename].dmm"
	return ..()

/datum/map_template/interior/medium_tank
	name = "medium tank interior template"
	filename = "tank"
