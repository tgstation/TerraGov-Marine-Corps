// -- Docks
/obj/docking_port/stationary/crashmode
	id = "canterbury_dock"
	name = "Canterbury Crash Site"
	dir = SOUTH
	width = 15
	height = 24
	dwidth = 7
	dheight = 12


/obj/docking_port/stationary/crashmode/on_crash()
	//clear areas around the shuttle with explosions
	var/turf/C = return_center_turf()

	var/cos = 1
	var/sin = 0
	switch(dir)
		if(WEST)
			cos = 0
			sin = 1
		if(SOUTH)
			cos = -1
			sin = 0
		if(EAST)
			cos = 0
			sin = -1

	var/updown = (round(width/2))*sin + (round(height/2))*cos
	var/leftright = (round(width/2))*cos - (round(height/2))*sin

	var/turf/front = locate(C.x, C.y - updown, C.z)
	var/turf/rear = locate(C.x, C.y + updown, C.z)
	var/turf/left = locate(C.x - leftright, C.y, C.z)
	var/turf/right = locate(C.x + leftright, C.y, C.z)

	var/turf/front_right = locate(C.x - round(leftright/2), C.y - round(updown/2), C.z)
	var/turf/front_left = locate(C.x + round(leftright/2), C.y - round(updown/2), C.z)
	var/turf/rear_right = locate(C.x - round(leftright/2), C.y + round(updown/2), C.z)
	var/turf/rear_left = locate(C.x + round(leftright/2), C.y + round(updown/2), C.z)


	// Big explosions
	explosion(front, 3, 4, 7, 0)
	explosion(rear, 3, 4, 7, 0)
	explosion(left, 3, 4, 7, 0)
	explosion(right, 3, 4, 7, 0)

	explosion(front_right, 4, 6, 10, 0)
	explosion(front_left, 4, 6, 10, 0)
	explosion(rear_right, 4, 6, 10, 0)
	explosion(rear_left, 3, 4, 7, 0)


/obj/docking_port/stationary/crashmode/loading
	id = "canterbury_loadingdock"
	name = "Low Orbit"

/obj/docking_port/stationary/crashmode/loading/on_crash()
	return // No explosions please and thank you.

// -- Shuttles
/obj/docking_port/mobile/crashmode
	name = "TGS Canterbury"
	dir = SOUTH
	width = 15
	height = 24
	dwidth = 7
	dheight = 12

	callTime = 10 MINUTES
	ignitionTime = 5 SECONDS
	prearrivalTime = 12 SECONDS

	var/list/spawnpoints = list()
	var/list/latejoins = list()
	var/list/spawns_by_job = list()

/obj/docking_port/mobile/crashmode/register()
	. = ..()
	SSshuttle.canterbury = src
