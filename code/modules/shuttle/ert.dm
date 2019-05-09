// small ert shuttles
/obj/docking_port/stationary/ert
	name = "ert shuttle"
	id = "distress"
	dir = SOUTH
	dwidth = 3
	width = 7
	height = 13

/obj/docking_port/stationary/ert/loading
	id = "distress_loading"

/obj/docking_port/stationary/ert/target
	id = "distress_target"

/obj/docking_port/mobile/ert
	name = "ert shuttle"
	dir = SOUTH
	dwidth = 5
	width = 11
	height = 21
	var/list/mob_spawns = list()
	var/list/item_spawns = list()

/obj/docking_port/mobile/ert/proc/get_destinations()
	var/list/docks = list()
	for(var/obj/docking_port/stationary/S in SSshuttle.stationary)
		if(S.id == "distress_target")
			if(canDock(S) == SHUTTLE_CAN_DOCK) // discards occupied docks
				docks += S
	for(var/i in SSshuttle.ert_shuttles)
		var/obj/docking_port/mobile/ert/E = i
		if(E.destination in docks)
			docks -= E.destination // another shuttle already headed there
	return docks

/obj/docking_port/mobile/ert/proc/auto_launch()
	var/obj/docking_port/stationary/S = pick(get_destinations())
	if(!S)
		return FALSE
	SSshuttle.moveShuttle(src, S, 1)
	return TRUE

/obj/docking_port/mobile/ert/Destroy(force)
	. = ..()
	if(force)
		SSshuttle.ert_shuttles -= src

/obj/docking_port/mobile/ert/register()
	. = ..()
	SSshuttle.ert_shuttles += src
	for(var/t in return_turfs())
		var/turf/T = t
		for(var/obj/effect/landmark/L in T.GetAllContents())
			if(istype(L, /obj/effect/landmark/distress))
				mob_spawns += L
			else if(istype(L, /obj/effect/landmark/distress_item))
				item_spawns += L
