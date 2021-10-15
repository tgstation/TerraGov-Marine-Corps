// -- Docks
/obj/docking_port/stationary/crashmode
	id = "canterbury_dock"
	name = "Canterbury Crash Site"
	dir = SOUTH
	width = 19
	height = 31
	dwidth = 9
	dheight = 15
	hidden = TRUE  //To make them not block landings during distress

// Big explosions

/*	explosion(front, 3, 4, 7, 0)
	explosion(rear, 3, 4, 7, 0)
	explosion(left, 3, 4, 7, 0)
	explosion(right, 3, 4, 7, 0)

	explosion(front_right, 4, 6, 10, 0)
	explosion(front_left, 4, 6, 10, 0)
	explosion(rear_right, 4, 6, 10, 0)
	explosion(rear_left, 3, 4, 7, 0)
*/

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

/obj/docking_port/stationary/crashmode/hangar
	name = "Hangar Pad One"
	id = "canterbury"
	roundstart_template = /datum/map_template/shuttle/tgs_canterbury

/obj/docking_port/mobile/crashmode/bigbury
	name = "TGS Bigbury"
	dir = SOUTH
	width = 19
	height = 31
	dwidth = 9
	dheight = 15
