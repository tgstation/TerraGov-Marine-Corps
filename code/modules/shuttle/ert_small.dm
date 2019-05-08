// small ert shuttles
/obj/docking_port/stationary/ert
	name = "ert shuttle"
	id = "distress"
	dir = SOUTH
	dwidth = 3
	width = 7
	height = 13

/obj/docking_port/mobile/ert
	name = "ert shuttle"
	dir = SOUTH
	dwidth = 5
	width = 11
	height = 21
	var/list/mob_spawns = list()
	var/list/item_spawns = list()

/obj/docking_port/mobile/ert_small/register()
	. = ..()
	for(var/t in return_turfs())
		var/turf/T = t
		for(var/obj/effect/landmark/L in T.GetAllContents())
			if(istype(L, /obj/effect/landmark/distress))
				mob_spawns += L
			else if(istype(L, /obj/effect/landmark/distress_item))
				item_spawns += L
