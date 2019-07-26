/obj/docking_port/stationary/crashmode
	id = "canterbury_dock"
	dir = SOUTH
	width = 15
	height = 24
	dwidth = 7
	dheight = 12

// /obj/docking_port/stationary/crashmode/on_crash()
// 	. = ..()
// 	//clear areas around the shuttle with explosions
// 	var/turf/C = return_center_turf()

// 	var/cos = 1
// 	var/sin = 0
// 	switch(dir)
// 		if(WEST)
// 			cos = 0
// 			sin = 1
// 		if(SOUTH)
// 			cos = -1
// 			sin = 0
// 		if(EAST)
// 			cos = 0
// 			sin = -1

// 	var/updown = (round(width/2))*sin + (round(height/2))*cos
// 	var/leftright = (round(width/2))*cos - (round(height/2))*sin

// 	var/turf/front = locate(C.x, C.y - updown, C.z)
// 	var/turf/rear = locate(C.x, C.y + updown, C.z)
// 	var/turf/left = locate(C.x - leftright, C.y, C.z)
// 	var/turf/right = locate(C.x + leftright, C.y, C.z)

// 	explosion(front, 0, 4, 8, 0)
// 	explosion(rear, 2, 5, 9, 0)
// 	explosion(left, 2, 5, 9, 0)
// 	explosion(right, 2, 5, 9, 0)

/obj/docking_port/stationary/crashmode/loading
	id = "canterbury_loadingdock"
	
/obj/docking_port/mobile/crashmode
	name = "tgs canterbury"
	dir = SOUTH
	width = 15
	height = 24
	dwidth = 7
	dheight = 12

	var/list/spawnpoints = list()
	var/list/marine_spawns_by_job = list()
	var/list/airlocks = list()

/obj/docking_port/mobile/crashmode/register()
	. = ..()
	SSshuttle.canterbury = src

/obj/docking_port/mobile/crashmode/proc/lockdown_airlocks()
	for(var/i in airlocks)
		var/obj/machinery/door/poddoor/almayer/D = i
		D.close()
		D.locked = TRUE

/obj/docking_port/mobile/crashmode/proc/unlock_airlocks()
	for(var/i in airlocks)
		var/obj/machinery/door/poddoor/almayer/D = i
		D.locked = FALSE

// Obj injection

/obj/machinery/door/poddoor/almayer/connect_to_shuttle(obj/docking_port/mobile/port, obj/docking_port/stationary/dock, idnum, override)
	. = ..()
	if(!istype(port, /obj/docking_port/mobile/crashmode))
		return
	var/obj/docking_port/mobile/crashmode/D = port
	D.airlocks += src
