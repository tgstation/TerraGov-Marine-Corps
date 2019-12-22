/atom/movable/proc/supply_export()
	. = 0
	for(var/datum/supply_export in GLOB.exports_types)
		var/datum/supply_export/E = supply_export
		if(type == E.export_obj)
			. = E.cost
	SSpoints.supply_points += .
